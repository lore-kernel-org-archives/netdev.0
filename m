From: kuznet@ms2.inr.ac.ru
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 26 Sep 2002 17:09:11 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209261309.RAA17837@sex.inr.ac.ru>
References: <20020926054721.GA6039@samba.org>
Mime-Version: 1.0
Cc: davem@redhat.com, ak@muc.de, netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mbp@samba.org (Martin Pool)
In-Reply-To: <20020926054721.GA6039@samba.org> from "Martin Pool" at Sep 26, 2 03:47:46 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I was also a bit confused by the purpose of the (skb->len < mss_now)

Me too. :-)

It is not a bug though. See below.


> straight away.  The FIN packet will be transmitted before the other
> packets that are queued, even though they are earlier in sequence.
> So, assuming no selective ACK, it will arrive out of order and just
> have to be retransmitted later on.

No really. It is _enqueued_, not sent. So, the only effect of the check
is that when the last frame happens to be mss-sized, FIN will be sent separately
though it could be attached to data. Not a problem.


> The patch is just below.  It works with 2.2.22 too.  If somebody could
> let me know if it's OK I would appreciate it.

I think it is OK. But, to be honest, it is the case when I do not feel
brave enough to give 100% warranty. :-) I do not understand why
tcp_push_pending_frames() was not used there... maybe, there was some reason
not to use it.

Dave, do you not remember this?


> I think the interesting bit is absent from the dump because it really

No, look at it again. It contains only the first 20% of data.
All the data and acks before connection termination are _lost_.

Alexey
