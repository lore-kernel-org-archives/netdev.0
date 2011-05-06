From: Nicolas Kaiser <nikai@nikai.net>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files.
Date: Fri, 6 May 2011 15:01:14 +0200
Message-ID: <20110506150114.25513c92@absol.kitzblitz>
References: <20110506115037.GA3299@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Rafael Aquini <aquini@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:59756 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752661Ab1EFNDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 09:03:20 -0400
In-Reply-To: <20110506115037.GA3299@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rafael Aquini <aquini@linux.com>:
> While I was studying what bond_3ad has under its hood, I realized its coding
> style did not follow all Documentation/CodingStyle recommendations. As a tiny
> collaboration I did some mods there, in an attempt to make that code stick as
> closely as possible with Kernel's coding style.
> Modifications:
> 	* switched all comments from C99-style to C89-style.
> 	* replaced MAC_ADDRESS_COMPARE macro for compare_ether_addr()
> 
> Signed-off-by: Rafael Aquini <aquini@linux.com>
> ---
>  drivers/net/bonding/bond_3ad.c |  836 +++++++++++++++++++++++-----------------
>  drivers/net/bonding/bond_3ad.h |  195 +++++-----
>  2 files changed, 579 insertions(+), 452 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 31912f1..fdb07be 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c

(..)

> @@ -1533,16 +1596,15 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>  
>  	if (best &&
>  	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
> -		/*
> -		 * For the STABLE policy, don't replace the old active
> -		 * aggregator if it's still active (it has an answering
> -		 * partner) or if both the best and active don't have an
> -		 * answering partner.
> +
> +		/* For the STABLE policy, don't replace the old active
> +		 * aggregator if it's still active (it has an answering partner)
> +		 * or if both the best and active don't have answering partners
>  		 */
>  		if (active && active->lag_ports &&
>  		    active->lag_ports->is_enabled &&
>  		    (__agg_has_partner(active) ||
> -		     (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
> +		    (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
>  			if (!(!active->actor_oper_aggregator_key &&
>  			      best->actor_oper_aggregator_key)) {
>  				best = NULL;

The indentation of parentheses looks correct to me in the original version.
However, this expression can also be simplified like

                if (active && active->lag_ports &&
                    active->lag_ports->is_enabled &&
-                   (__agg_has_partner(active) ||
-                    (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
+                   (__agg_has_partner(active) || !__agg_has_partner(best))) {
                        if (!(!active->actor_oper_aggregator_key &&
                              best->actor_oper_aggregator_key)) {
                                best = NULL;

Last October I submitted such a patch which also simplified the
double negation in the subsequent expression.

Best regards,
Nicolas Kaiser
