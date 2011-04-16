From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH v2] net: cxgb4{,vf}: convert to hw_features
Date: Sat, 16 Apr 2011 11:23:59 -0700
Message-ID: <4DA9DEBF.8050300@chelsio.com>
References: <20110415145050.6A43913A6A@rere.qmqm.pl> <20110416165226.B881F13A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11465 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab1DPSYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 14:24:08 -0400
In-Reply-To: <20110416165226.B881F13A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
> v2: cxgb4: remove now unneeded variable in t4_ethrx_handler()
>     cxgb4vf: fix hw/vlan_features values

Thanks for doing this.  The cxgb4 part looks good.  For cxgb4vf I have =
a=20
comment below.

> @@ -2638,19 +2597,18 @@ static int __devinit cxgb4vf_pci_probe(struct=
 pci_dev *pdev,
> -		netdev->features =3D (NETIF_F_SG | TSO_FLAGS |
> -				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> -				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
> -				    NETIF_F_GRO);
> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS | NETIF_F_RXCSUM |
> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +		netdev->vlan_features =3D NETIF_F_SG | TSO_FLAGS |
> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +			NETIF_F_HW_VLAN_TX | NETIF_F_HIGHDMA;

This NETIF_F_HW_VLAN_TX looks misplaced.  Did you mean to add it to=20
hw_features rather than vlan_features?
