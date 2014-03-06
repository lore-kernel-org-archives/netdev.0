From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/6] tipc: allow connection shutdown
 callback to be invoked in advance
Date: Wed, 05 Mar 2014 23:56:18 -0500 (EST)
Message-ID: <20140305.235618.31002872977881096.davem@davemloft.net>
References: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
	<1394006178-23966-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaCFE4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 23:56:22 -0500
In-Reply-To: <1394006178-23966-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 5 Mar 2014 08:56:13 +0100

> @@ -413,8 +411,11 @@ int tipc_conn_sendmsg(struct tipc_server *s, int conid,
>  	struct tipc_conn *con;
>  
>  	con = tipc_conn_lookup(s, conid);
> -	if (!con)
> +	if (!con) {
> +		pr_err("Connection %d not found on server %s\n", conid,
> +		       s->name);
>  		return -EINVAL;
> +	}
>  
>  	e = tipc_alloc_entry(data, len);
>  	if (!e) {

You really don't want to add kernel log messages which might be easily
triggerable by the user.  Please remove this.

This is the second such case I've pointed out in this patch set, please
audit the rest of your changes for the same issue before resubmitting
so we don't go into this loop yet another time.

Thank you.
