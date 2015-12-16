From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ipv6: allow setting stable_secret mode
Date: Wed, 16 Dec 2015 10:56:20 -0800
Message-ID: <20151216105620.331d28ab@xeon-e3>
References: <1450265408-20510-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36829 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934471AbbLPS4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 13:56:14 -0500
Received: by mail-pf0-f180.google.com with SMTP id o64so16433828pfb.3
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 10:56:13 -0800 (PST)
In-Reply-To: <1450265408-20510-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2015 12:30:08 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  ip/iplink.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index f30de86d1858a0..e824082f7d8149 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -84,7 +84,7 @@ void iplink_usage(void)
>  	fprintf(stderr, "				   [ state { auto | enable | disable} ] ]\n");
>  	fprintf(stderr, "			  [ master DEVICE ]\n");
>  	fprintf(stderr, "			  [ nomaster ]\n");
> -	fprintf(stderr, "			  [ addrgenmode { eui64 | none } ]\n");
> +	fprintf(stderr, "			  [ addrgenmode { eui64 | none | stable_secret } ]\n");
>  	fprintf(stderr, "	                  [ protodown { on | off } ]\n");
>  	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type TYPE]\n");
>  
> @@ -176,6 +176,8 @@ static int get_addr_gen_mode(const char *mode)
>  		return IN6_ADDR_GEN_MODE_EUI64;
>  	if (strcasecmp(mode, "none") == 0)
>  		return IN6_ADDR_GEN_MODE_NONE;
> +	if (strcasecmp(mode, "stable_secret") == 0)
> +		return IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
>  	return -1;
>  }
>  

ip options are supposed to be clse to invertable. ie what is displayed on show
command should match what are options for set.  There were even some VPN scripts
that depended on this.
