From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: add validation for the socket syscall
 protocol argument
Date: Mon, 14 Dec 2015 14:32:17 -0500 (EST)
Message-ID: <20151214.143217.492564448937971982.davem@davemloft.net>
References: <1450109869-23769-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbbLNTcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:32:19 -0500
In-Reply-To: <1450109869-23769-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 14 Dec 2015 17:17:49 +0100

> diff --git a/net/socket.c b/net/socket.c
> index 456fadb..d2f3d49 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1098,6 +1098,9 @@ int __sock_create(struct net *net, int family, int type, int protocol,
>  		return -EAFNOSUPPORT;
>  	if (type < 0 || type >= SOCK_MAX)
>  		return -EINVAL;
> +	/* upper bound should be tested by per-protocol .create callbacks */
> +	if (protocol < 0)
> +		return -EINVAL;
>  

Please get rid of this part of your patch and resubmit, thanks.
