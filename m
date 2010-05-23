From: walter harms <wharms@bfs.de>
Subject: Re: [patch] caif: cleanup: remove duplicate checks
Date: Sun, 23 May 2010 10:27:42 +0200
Message-ID: <4BF8E6FE.9000303@bfs.de>
References: <20100522204519.GW22515@bicker>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:43317 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306Ab0EWI1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 May 2010 04:27:49 -0400
In-Reply-To: <20100522204519.GW22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter schrieb:
> These checks merely duplicate the things we've asserted already.  In the
> case of the checks for null we've already dereferenced those variables
> as well.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
> index df43f26..cc2f072 100644
> --- a/net/caif/cfcnfg.c
> +++ b/net/caif/cfcnfg.c
> @@ -313,14 +313,10 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
>  	caif_assert(phyinfo->phy_layer != NULL);
>  	caif_assert(phyinfo->phy_layer->id == phyid);
>  
> -	if (phyinfo != NULL &&
> -	    phyinfo->phy_ref_count++ == 0 &&
> -	    phyinfo->phy_layer != NULL &&
> +	if (phyinfo->phy_ref_count++ == 0 &&
>  	    phyinfo->phy_layer->modemcmd != NULL) {
> -		caif_assert(phyinfo->phy_layer->id == phyid);
>  		phyinfo->phy_layer->modemcmd(phyinfo->phy_layer,
>  					     _CAIF_MODEMCMD_PHYIF_USEFULL);
> -
>  	}
>  	adapt_layer->id = channel_id;
>  


hi Dan,
the phyinfo->phy_ref_count++  is very hidden, perhaps in terms of readability
it is better to move the phyinfo->phy_ref_count++ inside.

just my 2 cents,

re,
 wh
