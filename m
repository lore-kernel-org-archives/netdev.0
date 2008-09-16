From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 09/14] Phonet: allocate and initialize new sockets
Date: Tue, 16 Sep 2008 22:42:52 +0400
Message-ID: <48CFFE2C.7050908@openvz.org>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58668 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754581AbYIPSnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2008 14:43:11 -0400
In-Reply-To: <1221577694-4513-9-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -71,8 +73,22 @@ static int pn_socket_create(struct net *net, struct socket *sock, int protocol)
>  		goto out;
>  	}
>  
> -	/* TODO: create and init the struct sock */
> -	err = -EPROTONOSUPPORT;
> +	sk = sk_alloc(net, PF_PHONET, GFP_KERNEL, pnp->prot);
> +	if (sk == NULL) {
> +		err = -ENOMEM;
> +		goto out;
> +	}

This turns to be a little bit messy wrt net namespaces.
Look - you allow for sockets to be created (and isolated from each
other) in each namespace, the list of devices is global, whilst
the sysctls are visible in init_net only...

I'd propose to either make this protocol namespaces aware from the
very beginning or to explicitly prohibit any operations with it in
the non-init netns not to forget to fix it in the future (just like
it was done for all the protocols and is still true for most of them).

Thanks,
Pavel
