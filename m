From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH] vlan: convert VLAN devices to use hw_features
Date: Fri, 1 Apr 2011 18:55:04 -0700
Message-ID: <AANLkTim68LoiyFA4+3weHkmuVpc=xxmHnheiEf_OH0LK@mail.gmail.com>
References: <20110331110135.19BE6138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45509 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab1DBBzZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 21:55:25 -0400
Received: by bwz15 with SMTP id 15so2905290bwz.19
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2011 18:55:24 -0700 (PDT)
In-Reply-To: <20110331110135.19BE6138DD@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/31 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index e34ea9e..b84a46b 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -704,8 +704,8 @@ static int vlan_dev_init(struct net_device *dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0(1<<__LINK_STATE_DORMANT))) |
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0(1<<__LINK_STATE_PRESENT);
>
> - =C2=A0 =C2=A0 =C2=A0 dev->features |=3D real_dev->features & real_d=
ev->vlan_features;
> - =C2=A0 =C2=A0 =C2=A0 dev->features |=3D NETIF_F_LLTX;
> + =C2=A0 =C2=A0 =C2=A0 dev->hw_features =3D real_dev->vlan_features &=
 NETIF_F_ALL_TX_OFFLOADS;
> + =C2=A0 =C2=A0 =C2=A0 dev->features |=3D real_dev->vlan_features | N=
ETIF_F_LLTX;

Shouldn't this continue to use real_dev->feaures &
real_dev->vlan_features?  In some places capabilities are blindly
added to vlan_features on the assumption that they will later be ANDed
with the real capabilities of the hardware (for example, see
register_netdevice()).
