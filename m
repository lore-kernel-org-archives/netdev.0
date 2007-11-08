From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH] No need to inc/dec packet_socks_nr if PACKET_REFCNT_DEBUG
 is not set
Date: Thu, 08 Nov 2007 13:51:30 +0300
Message-ID: <4732EA32.6060105@sw.ru>
References: <20071108103731.GA22373@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:53346 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753636AbXKHKry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 05:47:54 -0500
In-Reply-To: <20071108103731.GA22373@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pls disregard this, Pavel have sent one similar already

Denis V. Lunev wrote:
> No need to inc/dec packet_socks_nr if PACKET_REFCNT_DEBUG is not set.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> 
> --- ./net/packet/af_packet.c.packetrefcnt	2007-11-08 13:48:22.000000000 +0300
> +++ ./net/packet/af_packet.c	2007-11-08 13:54:29.000000000 +0300
> @@ -135,7 +135,9 @@ dev->hard_header == NULL (ll header is a
>     packet classifier depends on it.
>   */
>  
> +#ifdef PACKET_REFCNT_DEBUG
>  static atomic_t packet_socks_nr;
> +#endif
>  
>  
>  /* Private packet socket structures. */
> @@ -232,8 +234,8 @@ static void packet_sock_destruct(struct 
>  		return;
>  	}
>  
> -	atomic_dec(&packet_socks_nr);
>  #ifdef PACKET_REFCNT_DEBUG
> +	atomic_dec(&packet_socks_nr);
>  	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
>  #endif
>  }
> @@ -1005,7 +1007,9 @@ static int packet_create(struct net *net
>  	po->num = proto;
>  
>  	sk->sk_destruct = packet_sock_destruct;
> +#ifdef PACKET_REFCNT_DEBUG
>  	atomic_inc(&packet_socks_nr);
> +#endif
>  
>  	/*
>  	 *	Attach a protocol block
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

