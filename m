From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC v2 3/7] net: netfilter conntrack - add per-net functionality
 for SCTP protocol
Date: Mon, 16 Mar 2009 16:35:11 +0100
Message-ID: <49BE71AF.8050200@trash.net>
References: <20090311205706.141086138@gmail.com> <20090311210817.384140456@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48510 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbZCPPfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 11:35:16 -0400
In-Reply-To: <20090311210817.384140456@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> Module specific data moved into per-net site and being allocated/freed
> during net namespace creation/deletion.

> +#define ___PERNET_TO_DAT(i, j) \
> +	sn->sysctl_table[i].data = &sn->sctp_timeouts[j]
> +
> +	___PERNET_TO_DAT(0, SCTP_CONNTRACK_CLOSED);
> +	___PERNET_TO_DAT(1, SCTP_CONNTRACK_COOKIE_WAIT);
> +	___PERNET_TO_DAT(2, SCTP_CONNTRACK_COOKIE_ECHOED);
> +	___PERNET_TO_DAT(3, SCTP_CONNTRACK_ESTABLISHED);
> +	___PERNET_TO_DAT(4, SCTP_CONNTRACK_SHUTDOWN_SENT);
> +	___PERNET_TO_DAT(5, SCTP_CONNTRACK_SHUTDOWN_RECD);
> +	___PERNET_TO_DAT(6, SCTP_CONNTRACK_SHUTDOWN_ACK_SENT);
> +
> +#undef ___PERNET_TO_DAT
> +
> +	sn->sysctl_header = register_net_sysctl_table(net,
> +			nf_net_netfilter_sysctl_path, sn->sysctl_table);
> +	if (!sn->sysctl_header)
> +		goto out_free;
> +
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	sn->compat_sysctl_table = kmemdup(sctp_compat_sysctl_table,
> +			sizeof(sctp_compat_sysctl_table), GFP_KERNEL);
> +	if (!sn->compat_sysctl_table)
> +		goto out_sysctl;
> +
> +#define ___PERNET_TO_DAT(i, j) \
> +	sn->compat_sysctl_table[i].data = &sn->sctp_timeouts[j]
> +
> +	___PERNET_TO_DAT(0, SCTP_CONNTRACK_CLOSED);
> +	___PERNET_TO_DAT(1, SCTP_CONNTRACK_COOKIE_WAIT);
> +	___PERNET_TO_DAT(2, SCTP_CONNTRACK_COOKIE_ECHOED);
> +	___PERNET_TO_DAT(3, SCTP_CONNTRACK_ESTABLISHED);
> +	___PERNET_TO_DAT(4, SCTP_CONNTRACK_SHUTDOWN_SENT);
> +	___PERNET_TO_DAT(5, SCTP_CONNTRACK_SHUTDOWN_RECD);
> +	___PERNET_TO_DAT(6, SCTP_CONNTRACK_SHUTDOWN_ACK_SENT);
> +
> +#undef ___PERNET_TO_DAT

This is really ugly and is somewhat risky since those magic offsets need
to be kept in sync. Any chance (I don't have a suggestion currently) to
do this in a nicer way?
