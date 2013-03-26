From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] VXLAN: Precompute vin for VXLAN header.
Date: Tue, 26 Mar 2013 14:43:18 -0400
Message-ID: <OF112514D1.BA5AC352-ON85257B3A.00666CE7-85257B3A.0066D5ED@us.ibm.com>
References: <1364322539-27141-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, jesse@nicira.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59806 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab3CZSri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 14:47:38 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 26 Mar 2013 12:47:36 -0600
In-Reply-To: <1364322539-27141-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 03/26/2013 02:28:59 PM:
 Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
 
> @@ -1006,7 +1004,7 @@ static netdev_tx_t vxlan_xmit_one(struct 
> sk_buff *skb, struct net_device *dev,
> 
>     vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
>     vxh->vx_flags = htonl(VXLAN_FLAGS);
> -   vxh->vx_vni = htonl(vni << 8);
> +   vxh->vx_vni = vxlan->vni;

        This is not correct since vni != vxlan->vni if an alternate
vni is specified via the fdb entry. You would need to also store
the fdb vni's as htonl(vni<<<8) and translate those back for netlink
dump operations, too.

                                                        +-DLS
