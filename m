From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Mon, 20 Sep 2010 15:52:56 -0400
Message-ID: <20100920195256.GA14330@elliptictech.com>
References: <20100920174443.GA5515@elliptictech.com>
 <1285006844.2323.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285006844.2323.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-09-20 20:20 +0200, Eric Dumazet wrote:
> If you change your program to send small frames (so they are not
> fragmented), is the problem still present ?

I changed MAX_DGRAM_SIZE in the test program to 1000 (mtu on the
interface is 1500).  The short answer is that the references are
not leaked, and things seem to get cleaned up.  So the rest of this
mail probably describes a separate issue.

The long answer, however, is interesting: With latest Linus' git, the
references are cleaned up much later than I would expect.  After running
the test program and flushing the SAD/SPD, the reference count is still
1.  If I repeat the test immediately, the reference count will increase
further.  I can easily raise the reference count to, say, 100.  Now, if
I wait a while (10 minutes or so), the reference count will still be
100.  However, when I run the setkey script after this delay, the
reference count drops immediately to 1.  If I then flush the SAD/SPD, it
drops to 0.

This behaviour is new: newer than the reported leak.  For example, with
2.6.34, everything works perfectly with MAX_DGRAM_SIZE set to 1000 (the
SAs are destroyed immediately when the SAD/SPD are flushed), but the
leak occurs with MAX_DGRAM_SIZE set to 10000.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
