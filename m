From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 17:51:22 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409291744500.3434-100000@dexter.psc.edu>
References: <20040929214350.GA26714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Nivedita Singhvi <niv@us.ibm.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929214350.GA26714@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, Andi Kleen wrote:

> > I need to see the crash folks are seeing.  Does it only happen
> > when you have tcpdump attached to the interface running the
> > test?  Does it happen only on the sender or the receiver
>
> It happens without tcpdump too.

Ditto.

> > in the netperf test?  Those would be a good clues, indicating
>
> The sender first gets slow, then eventually crashes.

I managed to get a tcpdump of one flow.  I accidentally deleted it, but
from memory what I saw was it ramped up to large virtual segments, then
got a partial ack for it (all but the last real segment -- delayed ack
here) then later after the full ack got back sent one small segment.
This segment was acked, but it never seemed to recognize this ack and
repeatedly retransmitted it after timeouts.  (Generating the retrans_out
leaked messages when the d-sacks came back.)

I can't conveniently get a backtrace of the crash right now.

  -John
