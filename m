From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG in tcp_timer.c:tcp_retransmit_timer()
Date: Mon, 29 Mar 2004 20:09:54 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040329200954.7baac255.davem@redhat.com>
References: <Pine.LNX.4.44.0403290222190.27795-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Tomar, Nagendra" <nagendra_tomar@adaptec.com>
In-Reply-To: <Pine.LNX.4.44.0403290222190.27795-100000@localhost.localdomain>
List-Id: netdev.vger.kernel.org

On Mon, 29 Mar 2004 02:39:01 +0530 (IST)
Nagendra Singh Tomar <nagendra_tomar@adaptec.com> wrote:

> While reading the code of tcp_retransmit_timer(), I came across something 
> which looks liks a BUG.

It isn't, read below.

> The following line 
> 
> if (tcp_retransmit_skb(sk, skb_peek(&sk->write_queue)) > 0)
> 
> should correctly read as
> 
> if (tcp_retransmit_skb(sk, skb_peek(&sk->write_queue)) < 0)

Nope, it really does want greater than zero.  Less than zero
means memory allocation error or something like that, but this is
not what this code wants to check for.  Read the comment inside
this code block, it says it is the code path for "local congestion"
and the device output path indicates congestion via positive valued
error codes.

These codes are the NET_XMIT_* and NET_RX_* macros defined in
linux/netdevice.h

Thanks for the report though.
