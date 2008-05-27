From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/3] virtio: fix delayed xmit of packet and freeing of
	old packets.
Date: Tue, 27 May 2008 12:01:08 +0100
Message-ID: <1211886068.3637.42.camel@muff>
References: <200805261742.43215.rusty@rustcorp.com.au>
	 <200805261748.13449.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756484AbYE0LBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 07:01:49 -0400
In-Reply-To: <200805261748.13449.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-26 at 17:48 +1000, Rusty Russell wrote:
> Because we cache the last failed-to-xmit packet, if there are no
> packets queued behind that one we may never send it (reproduced here
> as TCP stalls, "cured" by an outgoing ping).

...

> diff -r 1d1ff03de434 drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c	Mon May 26 11:03:26 2008 +1000
> +++ b/drivers/net/virtio_net.c	Mon May 26 16:37:20 2008 +1000
...
> @@ -432,6 +452,8 @@ static int virtnet_probe(struct virtio_d
>  	skb_queue_head_init(&vi->recv);
>  	skb_queue_head_init(&vi->send);
>  
> +	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
> +
>  	err = register_netdev(dev);

Missing a tasklet_kill() in virtnet_remove() ?

Cheers,
Mark.

