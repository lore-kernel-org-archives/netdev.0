From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] vmxnet3: Convert to new vlan model.
Date: Wed, 29 Jun 2011 13:06:25 +0200
Message-ID: <BANLkTikiZmj42XXeBTNBgpbEWiqFRasV6w@mail.gmail.com>
References: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:58452 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab1F2LGr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 07:06:47 -0400
Received: by qyk9 with SMTP id 9so640935qyk.19
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 04:06:46 -0700 (PDT)
In-Reply-To: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/24 Jesse Gross <jesse@nicira.com>:
> This converts the vmxnet3 driver to use the new vlan model. =C2=A0In =
doing so
> it fixes missing tags in tcpdump and failure to do checksum offload w=
hen
> tx vlan offload is disabled.
[...]
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
[...]
> @@ -2639,12 +2588,13 @@ vmxnet3_declare_features(struct vmxnet3_adapt=
er *adapter, bool dma64)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev->hw_features =3D NETIF_F_SG | NETIF=
_F_RXCSUM |
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0NETIF_F_HW_CSU=
M | NETIF_F_HW_VLAN_TX |
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_TSO | NETI=
=46_F_TSO6 | NETIF_F_LRO;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_VLAN_RX=
 | NETIF_F_TSO | NETIF_F_TSO6 |
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_LRO;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dma64)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev->featur=
es |=3D NETIF_F_HIGHDMA;

***

> - =C2=A0 =C2=A0 =C2=A0 netdev->vlan_features =3D netdev->hw_features =
& ~NETIF_F_HW_VLAN_TX;
> - =C2=A0 =C2=A0 =C2=A0 netdev->features =3D netdev->hw_features |
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_HW_VLAN_RX=
 | NETIF_F_HW_VLAN_FILTER;
> + =C2=A0 =C2=A0 =C2=A0 netdev->vlan_features =3D netdev->hw_features =
&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_V=
LAN_RX);
> + =C2=A0 =C2=A0 =C2=A0 netdev->features =3D netdev->hw_features | NET=
IF_F_HW_VLAN_FILTER;

This will disable NETIF_F_HIGHDMA even if dma64 =3D=3D true. I propose =
a
fix that sets NETIF_F_HIGHDMA
in hw_features instead of features at line before '***' mark.

Best Regards,
Micha=C5=82 Miros=C5=82aw
