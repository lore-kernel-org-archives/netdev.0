From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] virtio: fix virtio_net xmit of freed skb bug
Date: Fri, 30 May 2008 22:12:40 -0400
Message-ID: <4840B418.5060607@garzik.org>
References: <200805261742.43215.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37086 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbYEaCMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:12:41 -0400
In-Reply-To: <200805261742.43215.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> If we fail to transmit a packet, we assume the queue is full and put
> the skb into last_xmit_skb.  However, if more space frees up before we
> xmit it, we loop, and the result can be transmitting the same skb twice.
> 
> Fix is simple: set skb to NULL if we've used it in some way, and check
> before sending.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/virtio_net.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)

applied 1-2 (#3 was already applied)


