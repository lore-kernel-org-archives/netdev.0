From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] NetLabel: Verify sensitivity level has a valid CIPSO
 mapping
Date: Wed, 28 Feb 2007 15:45:07 -0500 (EST)
Message-ID: <Line.LNX.4.64.0702281544350.9150@d.namei>
References: <20070228200140.491071752@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:51564 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbXB1UpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 15:45:12 -0500
In-Reply-To: <20070228200140.491071752@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Feb 2007, Paul Moore wrote:

> The current CIPSO engine has a problem where it does not verify that the given
> sensitivity level has a valid CIPSO mapping when the "std" CIPSO DOI type is
> used.  The end result is that bad packets are sent on the wire which should
> have never been sent in the first place.  This patch corrects this problem by
> verifying the sensitivity level mapping similar to what is done with the
> category mapping.  This patch also changes the returned error code in this case
> to -EPERM to better match what the category mapping verification code returns.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

[removed redhat-lspp, which is subscriber only]

Acked-by: James Morris <jmorris@namei.org>


> ---
>  net/ipv4/cipso_ipv4.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: net-2.6_bugfix/net/ipv4/cipso_ipv4.c
> ===================================================================
> --- net-2.6_bugfix.orig/net/ipv4/cipso_ipv4.c
> +++ net-2.6_bugfix/net/ipv4/cipso_ipv4.c
> @@ -732,11 +732,12 @@ static int cipso_v4_map_lvl_hton(const s
>  		*net_lvl = host_lvl;
>  		return 0;
>  	case CIPSO_V4_MAP_STD:
> -		if (host_lvl < doi_def->map.std->lvl.local_size) {
> +		if (host_lvl < doi_def->map.std->lvl.local_size &&
> +		    doi_def->map.std->lvl.local[host_lvl] < CIPSO_V4_INV_LVL) {
>  			*net_lvl = doi_def->map.std->lvl.local[host_lvl];
>  			return 0;
>  		}
> -		break;
> +		return -EPERM;
>  	}
>  
>  	return -EINVAL;
> @@ -771,7 +772,7 @@ static int cipso_v4_map_lvl_ntoh(const s
>  			*host_lvl = doi_def->map.std->lvl.cipso[net_lvl];
>  			return 0;
>  		}
> -		break;
> +		return -EPERM;
>  	}
>  
>  	return -EINVAL;
> 
> --
> paul moore
> linux security @ hp
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
