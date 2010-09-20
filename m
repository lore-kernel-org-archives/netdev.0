From: David Miller <davem@davemloft.net>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Mon, 20 Sep 2010 13:00:47 -0700 (PDT)
Message-ID: <20100920.130047.124017922.davem@davemloft.net>
References: <20100920174443.GA5515@elliptictech.com>
	<1285006844.2323.17.camel@edumazet-laptop>
	<20100920195256.GA14330@elliptictech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: nbowler@elliptictech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756509Ab0ITUA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 16:00:28 -0400
In-Reply-To: <20100920195256.GA14330@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Bowler <nbowler@elliptictech.com>
Date: Mon, 20 Sep 2010 15:52:56 -0400

> On 2010-09-20 20:20 +0200, Eric Dumazet wrote:
>> If you change your program to send small frames (so they are not
>> fragmented), is the problem still present ?
> 
> I changed MAX_DGRAM_SIZE in the test program to 1000 (mtu on the
> interface is 1500).  The short answer is that the references are
> not leaked, and things seem to get cleaned up.  So the rest of this
> mail probably describes a separate issue.
> 
> The long answer, however, is interesting: With latest Linus' git, the
> references are cleaned up much later than I would expect.  After running
> the test program and flushing the SAD/SPD, the reference count is still
> 1.  If I repeat the test immediately, the reference count will increase
> further.  I can easily raise the reference count to, say, 100.  Now, if
> I wait a while (10 minutes or so), the reference count will still be
> 100.  However, when I run the setkey script after this delay, the
> reference count drops immediately to 1.  If I then flush the SAD/SPD, it
> drops to 0.

This is because we actually cache IPSEC routes correctly, previously
we'd create a new routing cache entry every time a lookup happened.

