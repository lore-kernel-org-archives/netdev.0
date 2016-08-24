From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 1/2] cxgb4/cxgb4vf: Add support for
 ndo_set_vf_vlan
Date: Wed, 24 Aug 2016 07:08:14 +0000
Message-ID: <SN2PR11MB009472734B1803F20C4A9B1497EA0@SN2PR11MB0094.namprd11.prod.outlook.com>
References: <1472021434-8287-1-git-send-email-hariprasad@chelsio.com>
 <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "leedom@chelsio.com" <leedom@chelsio.com>,
        "nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0129.outbound.protection.outlook.com ([104.47.37.129]:4222
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753471AbcHXHI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 03:08:26 -0400
In-Reply-To: <1472021434-8287-2-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -1202,6 +1202,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct
> net_device *dev)
>  	BUG_ON(qidx >=3D pi->nqsets);
>  	txq =3D &adapter->sge.ethtxq[pi->first_qset + qidx];
>=20
> +	if (pi->vlan_id && !skb_vlan_tag_present(skb))
> +		__vlan_hwaccel_put_tag(skb, cpu_to_be16(ETH_P_8021Q),
> +				       pi->vlan_id);
> +

So it's a purely SW implementation of the feature on the VF side?
Does the HW enforces the configuration in any way on the VF?

Also, looks like an already tagged packet would be processed with
the original vlan-id [instead of the one of PF has provided].
Is that intentional?
