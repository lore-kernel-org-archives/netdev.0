From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 25/29] net: vrf: Handle VRF any context
Date: Thu, 05 Feb 2015 14:46:22 +0100
Message-ID: <54D3742E.9020607@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-26-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:61526 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbbBENqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:46:24 -0500
Received: by mail-we0-f169.google.com with SMTP id x3so4096931wes.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:46:23 -0800 (PST)
In-Reply-To: <1423100070-31848-26-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> VRF any context applies only to tasks to and sockets. Devices are
> associated with a single VRF, and skb's by extension are connected to
> a single VRF.
>
> Listen sockets and unconnected sockets can be opened in a "VRF any"
> context allowing a single daemon to provide service across all VRFs
> in a namespace. Connected sockets must be in a specific vrf context.
> Accepted sockets acquire the VRF context from the device the packet
> enters (via the skb).
>
> "VRF any" context is also useful for tasks wanting to view L3/L4
> data for all VRFs.
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
[snip]
> +static inline int neigh_parms_net_ctx_eq_any(const struct neigh_parm=
s *parms,
> +					     const struct net_ctx *net_ctx)
> +{
> +#ifdef CONFIG_NET_NS
> +	if (net_eq(neigh_parms_net(parms), net_ctx->net) &&
> +	    (vrf_eq(neigh_parms_vrf(parms), net_ctx->vrf) ||
> +	     vrf_is_any(net_ctx->vrf))) {
> +		return 1;
> +	}
> +
> +	return 0;
> +#else
> +	return 1;
> +#endif
If I understand well, the way the patch is done, VRF can be used only i=
f=20
CONFIG_NET_NS is enabled.
But if I'm not wrong, it could be independent. Am I right?
