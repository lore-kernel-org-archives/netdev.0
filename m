From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: Add sysctl entry to disable MTU
 updates from RA
Date: Tue, 20 Jan 2015 00:01:04 +0100
Message-ID: <54BD8CB0.8050800@redhat.com>
References: <1421703363-3376-1-git-send-email-harouth@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbbASXBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 18:01:11 -0500
In-Reply-To: <1421703363-3376-1-git-send-email-harouth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2015 10:36 PM, Harout Hedeshian wrote:
...
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index 85b0221..da50faa 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -1287,6 +1287,13 @@ accept_ra_rtr_pref - BOOLEAN
>   	Functional default: enabled if accept_ra is enabled.
>   			    disabled if accept_ra is disabled.
>
> +accept_ra_mtu - BOOLEAN
> +	Apply the MTU value specified in RA option 5 (RFC4861). If
> +	disabled, the MTU specified in the RA will be ignored.
> +
> +	Functional default: enabled if accept_ra is enabled.
> +                            disabled if accept_ra is disabled.

Nit: please indent correctly with tab here.

> +
...
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 73cb02d..437a6a4 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -169,6 +169,7 @@ enum {
>   	DEVCONF_SUPPRESS_FRAG_NDISC,
>   	DEVCONF_ACCEPT_RA_FROM_LOCAL,
>   	DEVCONF_USE_OPTIMISTIC,
> +	DEVCONF_ACCEPT_RA_MTU,
>   	DEVCONF_MAX
>   };

You also need a corresponding ipv6_store_devconf() entry, otherwise
netlink dumps will always see this setting as disabled.
