From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/garp: avoid infinite loop if attribute already
 exists
Date: Mon, 26 Mar 2012 17:44:32 -0400 (EDT)
Message-ID: <20120326.174432.594293356850568957.davem@davemloft.net>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab2CZVog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 17:44:36 -0400
In-Reply-To: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Sun, 25 Mar 2012 18:43:56 -0400

> @@ -353,9 +361,9 @@ int garp_request_join(const struct net_device *dev,
>  
>  	spin_lock_bh(&app->lock);
>  	attr = garp_attr_create(app, data, len, type);
> -	if (!attr) {
> +	if (IS_ERR(attr)) {
>  		spin_unlock_bh(&app->lock);
> -		return -ENOMEM;
> +		return ERR_PTR(attr);

You cannot tell me that this ERR_PTR() thing didn't emit a very loud
warning from the compiler.  You want PTR_ERR() instead.

Please don't be so careless, if I can predict compiler warnings just
by reading your patches you are so doing it wrong.
