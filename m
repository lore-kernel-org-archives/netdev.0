From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Temporary IPv6 address asignment
Date: Sun, 03 May 2009 16:58:02 -0700
Message-ID: <m1skjlrb79.fsf@fess.ebiederm.org>
References: <49FE107A.4020406@poczta.fm>
	<20090503.144758.222061423.davem@davemloft.net>
	<49FE18C3.7040702@poczta.fm>
	<20090503.153428.07349534.davem@davemloft.net>
	<49FE1E71.6090500@poczta.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Lukasz Stelmach <stlman@poczta.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60732 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbZECX6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 19:58:10 -0400
In-Reply-To: <49FE1E71.6090500@poczta.fm> (Lukasz Stelmach's message of "Mon\, 04 May 2009 00\:45\:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lukasz Stelmach <stlman@poczta.fm> writes:

I don't know about the rest of your patch the sysctl hunks are wrong.

> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index e76d3b2..951ba2c 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -570,15 +570,16 @@ enum {
>  	NET_IPV6_TEMP_PREFERED_LFT=13,
>  	NET_IPV6_REGEN_MAX_RETRY=14,
>  	NET_IPV6_MAX_DESYNC_FACTOR=15,
> -	NET_IPV6_MAX_ADDRESSES=16,
> -	NET_IPV6_FORCE_MLD_VERSION=17,
> -	NET_IPV6_ACCEPT_RA_DEFRTR=18,
> -	NET_IPV6_ACCEPT_RA_PINFO=19,
> -	NET_IPV6_ACCEPT_RA_RTR_PREF=20,
> -	NET_IPV6_RTR_PROBE_INTERVAL=21,
> -	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
> -	NET_IPV6_PROXY_NDP=23,
> -	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
> +	NET_IPV6_DESYNC_FACTOR=16,
> +	NET_IPV6_MAX_ADDRESSES=17,
> +	NET_IPV6_FORCE_MLD_VERSION=18,
> +	NET_IPV6_ACCEPT_RA_DEFRTR=19,
> +	NET_IPV6_ACCEPT_RA_PINFO=20,
> +	NET_IPV6_ACCEPT_RA_RTR_PREF=21,
> +	NET_IPV6_RTR_PROBE_INTERVAL=22,
> +	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=23,
> +	NET_IPV6_PROXY_NDP=24,
> +	NET_IPV6_ACCEPT_SOURCE_ROUTE=26,
>  	__NET_IPV6_MAX
>  };

These are numbers used in the kernel sysctl binary ABI.  You just
changed them breaking the ABI, when you put NET_IPV6_DESYNC_FACTOR in
the middle.

> @@ -4124,6 +4167,14 @@ static struct addrconf_sysctl_table
>  			.data		=	&ipv6_devconf.max_desync_factor,
>  			.maxlen		=	sizeof(int),
>  			.mode		=	0644,
> +			.proc_handler	=	addrconf_sysctl_desync,
> +		},
> +		{
> +			.ctl_name	=	NET_IPV6_DESYNC_FACTOR,
> +			.procname	=	"desync_factor",
> +			.data		=	&ipv6_devconf.desync_factor,
> +			.maxlen		=	sizeof(int),
> +			.mode		=	0444,
>  			.proc_handler	=	proc_dointvec,
 		},

The sysctl binary abi is currently frozen and deprecated.  Which means
you should set .ctl_name = CTL_UNNUMBERED or simply omit ctl_name on
new sysctl entries.

Eric
