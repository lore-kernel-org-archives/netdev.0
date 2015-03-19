From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix build issue when building without IPv6
Date: Thu, 19 Mar 2015 15:04:33 -0400 (EDT)
Message-ID: <20150319.150433.850095478975909930.davem@davemloft.net>
References: <1426778023-27486-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, erik.hugne@ericsson.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbbCSTEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:04:37 -0400
In-Reply-To: <1426778023-27486-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 19 Mar 2015 12:13:43 -0300

> @@ -387,6 +391,11 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
>  	tuncfg.encap_destroy = NULL;
>  	setup_udp_tunnel_sock(net, ub->ubsock, &tuncfg);
>  
> +	/* At this point, IPv6 module should have been loaded in
> +	 * udp_sock_create/sock_create_kern().
> +	 */
> +	BUG_ON(!ipv6_stub);
> +

If IPV6=n this will be NULL no matter what.

And if the module load gets an error, this will be NULL as well.
