From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af-packet: Use existing netdev reference for bound
 sockets.
Date: Thu, 26 May 2011 14:22:42 -0400 (EDT)
Message-ID: <20110526.142242.1208813086960140191.davem@davemloft.net>
References: <1306365332-12105-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491Ab1EZSWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 14:22:45 -0400
In-Reply-To: <1306365332-12105-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed, 25 May 2011 16:15:32 -0700

> @@ -1161,6 +1168,7 @@ static int packet_snd(struct socket *sock,
>  
>  	if (saddr == NULL) {
>  		ifindex	= po->ifindex;
> +		dev = po->prot_hook.dev;
>  		proto	= po->num;
>  		addr	= NULL;
>  	} else {
> @@ -1174,8 +1182,11 @@ static int packet_snd(struct socket *sock,
>  		addr	= saddr->sll_addr;
>  	}
>  
> +	if (!dev) {
> +		dev = dev_get_by_index(sock_net(sk), ifindex);
> +		need_rls_dev = true;
> +	}
>  

Why don't you move this second hunk into the "saddr != NULL" code
block?

That way all you can:

1) Call dev_get_by_index() unconditionally from that spot.

2) Only have the dev==NULL check right afterwards inside of the
   unbound case as well.
