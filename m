From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: use sock_valbool_flag to set/clear SOCK_RXQ_OVFL
Date: Fri, 7 Oct 2011 09:40:23 -0400
Message-ID: <20111007134023.GC11408@hmsreliant.think-freely.org>
References: <1317994221.3988.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57979 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760019Ab1JGNka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 09:40:30 -0400
Content-Disposition: inline
In-Reply-To: <1317994221.3988.12.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 03:30:20PM +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no point in open-coding sock_valbool_flag().
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/core/sock.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> --- a/net/core/sock.c	2011-10-07 15:26:30.000000000 +0200
> +++ b/net/core/sock.c	2011-10-07 15:27:46.000000000 +0200
> @@ -738,10 +738,7 @@ set_rcvbuf:
>  		/* We implement the SO_SNDLOWAT etc to
>  		   not be settable (1003.1g 5.3) */
>  	case SO_RXQ_OVFL:
> -		if (valbool)
> -			sock_set_flag(sk, SOCK_RXQ_OVFL);
> -		else
> -			sock_reset_flag(sk, SOCK_RXQ_OVFL);
> +		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
>  		break;
>  	default:
>  		ret = -ENOPROTOOPT;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Looks good, thanks Johannes!
Acked-by: Neil Horman <nhorman@tuxdriver.com>
