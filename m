From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/5] team: add support for per-port options
Date: Tue, 10 Apr 2012 14:33:56 -0400 (EDT)
Message-ID: <20120410.143356.28893999541977853.davem@davemloft.net>
References: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
	<1334070946-7704-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2DJSd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:33:59 -0400
In-Reply-To: <1334070946-7704-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 10 Apr 2012 17:15:42 +0200

> @@ -81,7 +81,16 @@ EXPORT_SYMBOL(team_port_set_team_mac);
>   * Options handling
>   *******************/
>  
> -struct team_option *__team_find_option(struct team *team, const char *opt_name)
> +struct team_option_inst { /* One for each option instance */
> +	struct list_head list;
> +	struct team_option *option;
> +	struct team_port *port; /* != NULL if per-port */
> +	bool changed;
> +	bool removed;
> +};
> +

All this indirection... just simply embed struct team_option into
struct team_option_inst instead of using a pointer, and allocate a
full team_option_inst where you currently memdup in the options.
