From: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
Subject: Re: BUG in tcp_timer.c:tcp_retransmit_timer()
Date: Tue, 30 Mar 2004 02:10:45 +0530 (IST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0403300207310.27795-100000@localhost.localdomain>
References: <20040329215057.3fd40210.davem@redhat.com>
Reply-To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>,
	<linux-net@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040329215057.3fd40210.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2004, David S. Miller wrote:

> On Mon, 29 Mar 2004 22:54:14 +0530 (IST)
> Nagendra Singh Tomar <nagendra_tomar@adaptec.com> wrote:
> 
> > 	Thats right. But what about the other cases of retransmission 
> > failures for which we are having a negative return (-ENOMEM, -EAGAIN, 
> > -EHOSTUNREACH etc). Even for these cases its not a good idea to 
> > artificially increment tp->retransmits, lest in some extreme case we might 
> > timeout a connection without a single packet going on the wire.
> 
> That's just like the packet getting dropped at the next hop,
> and not the case this branch of code intends to deal with.
> 

I understand your point, but we should try our best to retransmit uptill 
the "max retransmission count". Packets can be dropped at any hop, 
but thats excatly why TCP doess a large number of retransmissions, 
before giving up. Whats wrong in having the check as 

if (tcp_retransmit_skb(sk, skb_peek(&sk->write_queue)) != 0)

so that we take care of both the cases. Does it have any bad effects ?



Thanx,
tomar


-- You have moved the mouse. Windows must be restarted for the 
   changes to take effect.

