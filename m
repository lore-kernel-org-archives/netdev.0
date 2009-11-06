From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Fri, 06 Nov 2009 16:21:29 +0100
Message-ID: <4AF43EF9.3020707@trash.net>
References: <1254473048.3959.76.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64401 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757859AbZKFPV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 10:21:26 -0500
In-Reply-To: <1254473048.3959.76.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> When we want to keep track of resources associated with applications, we
> need to know when an app is going away. Add a notification function to
> netlink that tells us that, and also hook it up to generic netlink so
> generic netlink can notify the families. Due to the way generic netlink
> works though, we need to notify all families and they have to sort out
> whatever resources some commands associated with the socket themselves.
> 

> @@ -166,6 +167,9 @@ static void netlink_sock_destruct(struct
>  		return;
>  	}
>  
> +	if (nlk->destruct)
> +		nlk->destruct(sk);
> +
>  	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
>  	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
>  	WARN_ON(nlk_sk(sk)->groups);


This seems pretty similar to the NETLINK_URELEASE notifier invoked
in netlink_release(). Wouldn't that one work as well?
