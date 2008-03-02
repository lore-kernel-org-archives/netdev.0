From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP] add missing sock_put() in pppol2tp_recv_dequeue()
Date: Sun, 02 Mar 2008 20:31:17 +0000
Message-ID: <47CB0E95.4040601@katalix.com>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com> <20080227105431.GA4527@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37853 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753819AbYCBUbU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 15:31:20 -0500
In-Reply-To: <20080227105431.GA4527@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

> Subject: [PPPOL2TP] add missing sock_put() in pppol2tp_recv_dequeue()
> 
> Every skb removed from session->reorder_q needs sock_put().
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Acked-by: James Chapman <jchapman@katalix.com>

> 
> ---
> 
>  drivers/net/pppol2tp.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> index e0b072d..dcd4991 100644
> --- a/drivers/net/pppol2tp.c
> +++ b/drivers/net/pppol2tp.c
> @@ -455,6 +455,7 @@ static void pppol2tp_recv_dequeue(struct pppol2tp_session *session)
>  			       skb_queue_len(&session->reorder_q));
>  			__skb_unlink(skb, &session->reorder_q);
>  			kfree_skb(skb);
> +			sock_put(session->sock);
>  			continue;
>  		}
>  


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

