From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip xfrm state: parse and print "icmp" and
 "af-unspec" flags
Date: Thu, 21 Jan 2010 10:10:54 -0800
Message-ID: <20100121101054.0de45e7c@nehalam>
References: <1263223421-14013-1-git-send-email-abadea@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Badea <abadea@ixiacom.com>
To: Alex Badea <abadea@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48568 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819Ab0AUSLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 13:11:00 -0500
In-Reply-To: <1263223421-14013-1-git-send-email-abadea@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jan 2010 17:23:41 +0200
Alex Badea <abadea@ixiacom.com> wrote:

> Convert to/from XFRM_STATE_ICMP and XFRM_STATE_AF_UNSPEC state flags.
> 
> Signed-off-by: Alex Badea <abadea@ixiacom.com>
> ---
>  ip/ipxfrm.c     |    2 ++
>  ip/xfrm_state.c |    6 +++++-
>  2 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
> index 18250de..7dc36f3 100644
> --- a/ip/ipxfrm.c
> +++ b/ip/ipxfrm.c
> @@ -780,6 +780,8 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
>  		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_DECAP_DSCP, "decap-dscp");
>  		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_NOPMTUDISC, "nopmtudisc");
>  		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
> +		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_ICMP, "icmp");
> +		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_AF_UNSPEC, "af-unspec");
>  		if (flags)
>  			fprintf(fp, "%x", flags);
>  	}
> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> index b1e3f22..32238ab 100644
> --- a/ip/xfrm_state.c
> +++ b/ip/xfrm_state.c
> @@ -83,7 +83,7 @@ static void usage(void)
>   	//fprintf(stderr, "REQID - number(default=0)\n");
>  
>  	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
> -	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv ]\n");
> +	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec ]\n");
>  
>          fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
>          fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
> @@ -210,6 +210,10 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
>  				*flags |= XFRM_STATE_NOPMTUDISC;
>  			else if (strcmp(*argv, "wildrecv") == 0)
>  				*flags |= XFRM_STATE_WILDRECV;
> +			else if (strcmp(*argv, "icmp") == 0)
> +				*flags |= XFRM_STATE_ICMP;
> +			else if (strcmp(*argv, "af-unspec") == 0)
> +				*flags |= XFRM_STATE_AF_UNSPEC;
>  			else {
>  				PREV_ARG(); /* back track */
>  				break;


applied
