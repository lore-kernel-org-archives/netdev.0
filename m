From: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
Subject: Re: BUG in tcp_timer.c:tcp_retransmit_timer()
Date: Mon, 29 Mar 2004 22:54:14 +0530 (IST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0403292251520.27795-100000@localhost.localdomain>
References: <20040329200954.7baac255.davem@redhat.com>
Reply-To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>,
	<linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040329200954.7baac255.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Dave,
	Thats right. But what about the other cases of retransmission 
failures for which we are having a negative return (-ENOMEM, -EAGAIN, 
-EHOSTUNREACH etc). Even for these cases its not a good idea to 
artificially increment tp->retransmits, lest in some extreme case we might 
timeout a connection without a single packet going on the wire.

Thanx,
tomar


 On Mon, 29 Mar 2004, David S. Miller wrote:

> On Mon, 29 Mar 2004 02:39:01 +0530 (IST)
> Nagendra Singh Tomar <nagendra_tomar@adaptec.com> wrote:
> 
> > While reading the code of tcp_retransmit_timer(), I came across something 
> > which looks liks a BUG.
> 
> It isn't, read below.
> 
> > The following line 
> > 
> > if (tcp_retransmit_skb(sk, skb_peek(&sk->write_queue)) > 0)
> > 
> > should correctly read as
> > 
> > if (tcp_retransmit_skb(sk, skb_peek(&sk->write_queue)) < 0)
> 
> Nope, it really does want greater than zero.  Less than zero
> means memory allocation error or something like that, but this is
> not what this code wants to check for.  Read the comment inside
> this code block, it says it is the code path for "local congestion"
> and the device output path indicates congestion via positive valued
> error codes.
> 
> These codes are the NET_XMIT_* and NET_RX_* macros defined in
> linux/netdevice.h
> 
> Thanks for the report though.
> 

-- 



-- You have moved the mouse. Windows must be restarted for the 
   changes to take effect.

