From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 13 Sep 2013 20:00:19 -0400 (EDT)
Message-ID: <20130913.200019.1803722327800834566.davem@davemloft.net>
References: <20130913215202.7D16C31C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffm@suse.com, isdn4linux@koppen.de,
	isdn@linux-pingi.de, jslaby@suse.cz,
	sergei.shtylyov@cogentembedded.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913Ab3INAAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 20:00:21 -0400
In-Reply-To: <20130913215202.7D16C31C1BF@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 13 Sep 2013 14:52:02 -0700

> @@ -612,6 +612,11 @@ data_sock_create(struct net *net, struct
>  {
>  	struct sock *sk;
>  
> +	if (!capable(CAP_SYS_ADMIN) &&
> +			!gid_eq(misdn_permitted_gid, current_gid()) &&
> +			!in_group_p(misdn_permitted_gid))
> +		return -EPERM;

This and the other conditional need to be styled correctly:

	if (a &&
	    b &&
	    c)

the object is to get the second and subsequent lines to start at the
first column after the openning parenthesis of the condition, using
the appropriate number of tab and space characters.
