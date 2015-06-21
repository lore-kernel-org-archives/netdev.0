From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] batman-adv: Avoid u32 overflow during gateway
 select
Date: Sun, 21 Jun 2015 09:37:13 -0700 (PDT)
Message-ID: <20150621.093713.572451264516042062.davem@davemloft.net>
References: <1434481584-1275-1-git-send-email-antonio@meshcoding.com>
	<1434481584-1275-2-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	ruben@freifunk-nrw.de, ruben@vfn-nrw.de, sven@narfation.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbbFUQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:25:28 -0400
In-Reply-To: <1434481584-1275-2-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 16 Jun 2015 21:06:23 +0200

> @@ -133,7 +133,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
>  	struct batadv_neigh_node *router;
>  	struct batadv_neigh_ifinfo *router_ifinfo;
>  	struct batadv_gw_node *gw_node, *curr_gw = NULL;
> -	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
> +	uint64_t max_gw_factor = 0, tmp_gw_factor = 0;
>  	uint32_t gw_divisor;

Divides are performed using these variables, so if you make
them 64-bit the build will fail.  You have to use one of the
routines in include/linux/math64.h in this situation, but
realize that this operation is now going to be quite expensive.
