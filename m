From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: add SO_MAX_DGRAM_QLEN for AF_UNIX SOCK_DGRAM
 sockets
Date: Tue, 03 Mar 2015 07:56:15 -0800
Message-ID: <1425398175.5130.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
	 <20150302.213807.367185406305242762.davem@davemloft.net>
	 <0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
	 <1425393019.5130.181.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55ee39bff7875967acb06f25fa695f95@iwakd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dan-+z8lB9qDZjnk1uMJSBkQmQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Seiler <christian-+GPkE3DhqnY@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55ee39bff7875967acb06f25fa695f95-+GPkE3DhqnY@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 16:05 +0100, Christian Seiler wrote:

> Doesn't this assume a typical datagram size of 256 bytes? Isn't that
> something that should be left up to the user? Also, suddenly the RCVBUF
> size of UNIX domain sockets suddenly becomes relevant, even though it
> is never actually checked when it comes to queuing the messages (only
> the SNDBUF size of the sending socket is checked). This creates really
> inconsistent semantics in my eyes where the receive buffer is useful
> for some things, but not for others.

Simple : If limit is expressed in term of packets, not in term of memory
usage, then the limit is in number of packets, not in bytes.

This is the reason we have pfifo and bfifo qdisc :
Admin can choose what he wants to limit on a device : packets or bytes.

If you want to allow the limitation being done in same SO_RCVBUF spirit,
you need to submit a patch for that.

(Using skb_set_owner_r() and tracking sk->sk_rmem_alloc instead of
skb_queue_len(&sk->sk_receive_queue) )
