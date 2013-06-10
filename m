From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V1 net-next 1/3] net/core: Add VF link state control
Date: Mon, 10 Jun 2013 15:39:36 +0100
Message-ID: <1370875176.1933.2.camel@bwh-desktop.uk.level5networks.com>
References: <1370784435-26055-1-git-send-email-ogerlitz@mellanox.com>
	 <1370784435-26055-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <ronye@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29972 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab3FJOjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 10:39:44 -0400
In-Reply-To: <1370784435-26055-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-09 at 16:27 +0300, Or Gerlitz wrote:
> From: Rony Efraim <ronye@mellanox.com>
> 
> Add netlink directives and ndo entry to allow for controling
> VF link, which can be in one of three states:
> 
> Auto - VF link state reflects the PF link state (default)
> 
> Up - VF link state is up, traffic from VF to VF works even if
> the actual PF link is down
> 
> Down - VF link state is down, no traffic from/to this VF, can be of
> use while configuring the VF
> 
> Signed-off-by: Rony Efraim <ronye@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -947,6 +947,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			struct ifla_vf_vlan vf_vlan;
>  			struct ifla_vf_tx_rate vf_tx_rate;
>  			struct ifla_vf_spoofchk vf_spoofchk;
> +			struct ifla_vf_link_state vf_linkstate;
>  
>  			/*
>  			 * Not all SR-IOV capable drivers support the

There's a bit missing here: you need to initialise ivi.linkstate to a
default value.  I'm not sure whether that should be
FLA_VF_LINK_STATE_AUTO (i.e. assume that's the default for all drivers/
hardware) or whether there should be an explicit 'unknown' value.

> @@ -961,13 +962,15 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			vf_mac.vf =
>  				vf_vlan.vf =
>  				vf_tx_rate.vf =
> -				vf_spoofchk.vf = ivi.vf;
> +				vf_spoofchk.vf =
> +				vf_linkstate.vf = ivi.vf;
>  
>  			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
>  			vf_vlan.vlan = ivi.vlan;
>  			vf_vlan.qos = ivi.qos;
>  			vf_tx_rate.rate = ivi.tx_rate;
>  			vf_spoofchk.setting = ivi.spoofchk;
> +			vf_linkstate.link_state = ivi.linkstate;
>  			vf = nla_nest_start(skb, IFLA_VF_INFO);
>  			if (!vf) {
>  				nla_nest_cancel(skb, vfinfo);
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
