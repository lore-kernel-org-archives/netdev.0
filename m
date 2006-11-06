From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211softmac: fix verbosity when debug disabled
Date: Mon, 06 Nov 2006 11:54:20 +0100
Message-ID: <1162810460.2762.21.camel@ux156>
References: <454CEA2E.mail3QE112KF3@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24239 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751601AbWKFKxQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 05:53:16 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <454CEA2E.mail3QE112KF3@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-11-04 at 13:29 -0600, Larry Finger wrote:
> SoftMAC contains a number of debug-type messages that continue to print
> even when debugging is turned off. This patch substitutes dprintkl for
> printkl for those lines.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Fine with me.
Acked-by: Johannes Berg <johannes@sipsolutions.net>


> Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
> +++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
> @@ -158,7 +158,7 @@ ieee80211softmac_auth_resp(struct net_de
>  	/* Make sure that we've got an auth queue item for this request */
>  	if(aq == NULL)
>  	{
> -		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
> +		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but no queue item exists.\n", MAC_ARG(auth->header.addr2));
>  		/* Error #? */
>  		return -1;
>  	}			
> @@ -166,7 +166,7 @@ ieee80211softmac_auth_resp(struct net_de
>  	/* Check for out of order authentication */
>  	if(!net->authenticating)
>  	{
> -		printkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
> +		dprintkl(KERN_DEBUG PFX "Authentication response received from "MAC_FMT" but did not request authentication.\n",MAC_ARG(auth->header.addr2));
>  		return -1;
>  	}
>  
> @@ -342,7 +342,7 @@ ieee80211softmac_deauth_req(struct ieee8
>  	/* Make sure the network is authenticated */
>  	if (!net->authenticated)
>  	{
> -		printkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
> +		dprintkl(KERN_DEBUG PFX "Can't send deauthentication packet, network is not authenticated.\n");
>  		/* Error okay? */
>  		return -EPERM;
>  	}
> @@ -376,7 +376,7 @@ ieee80211softmac_deauth_resp(struct net_
>  	net = ieee80211softmac_get_network_by_bssid(mac, deauth->header.addr2);
>  	
>  	if (net == NULL) {
> -		printkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
> +		dprintkl(KERN_DEBUG PFX "Received deauthentication packet from "MAC_FMT", but that network is unknown.\n",
>  			MAC_ARG(deauth->header.addr2));
>  		return 0;
>  	}
> @@ -384,7 +384,7 @@ ieee80211softmac_deauth_resp(struct net_
>  	/* Make sure the network is authenticated */
>  	if(!net->authenticated)
>  	{
> -		printkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
> +		dprintkl(KERN_DEBUG PFX "Can't perform deauthentication, network is not authenticated.\n");
>  		/* Error okay? */
>  		return -EPERM;
>  	}
> 
