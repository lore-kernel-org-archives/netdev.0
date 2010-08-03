From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: ixgbe_fcoe build break
Date: Tue, 3 Aug 2010 14:55:47 -0700
Message-ID: <AANLkTi==NOe4w-=yHw8KptSyCpT+ir9X32W3z2_km0sN@mail.gmail.com>
References: <1280851078-4263-1-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65535 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798Ab0HCVzs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 17:55:48 -0400
Received: by ywh1 with SMTP id 1so1729827ywh.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 14:55:47 -0700 (PDT)
In-Reply-To: <1280851078-4263-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 3, 2010 at 08:57, Jon Mason <jon.mason@exar.com> wrote:
> struct ixgbe_fcoe has fields that are #ifdef'ed with CONFIG_IXGBE_DCB=
=2E
> However, not all references to those fields check for CONFIG_IXGBE_DC=
B.
> This patch adds the necessary check to allow for ixgbe to compile.
>
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A04 ++++
> =C2=A01 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 7d6a415..9ec3dfe 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -6155,9 +6155,11 @@ static u16 ixgbe_select_queue(struct net_devic=
e *dev, struct sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0txq &=3D (adapter->ring_feature[RING_F_FCOE].indices - 1)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0txq +=3D adapter->ring_feature[RING_F_FCOE].mask;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return txq;
> +#ifdef CONFIG_IXGBE_DCB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else if (ada=
pter->flags & IXGBE_FLAG_DCB_ENABLED) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0txq =3D adapter->fcoe.up;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return txq;
> +#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0#endif
> @@ -6218,8 +6220,10 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_=
buff *skb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb->protocol =3D=3D htons(=
ETH_P_FIP))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tx_flags &=3D =
~(IXGBE_TX_FLAGS_VLAN_PRIO_MASK
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<< IXGBE_TX_FLAGS_VLAN_SHIFT);
> +#ifdef CONFIG_IXGBE_DCB
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tx_flags |=3D =
((adapter->fcoe.up << 13)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<< IXGBE_TX_FLAGS_VLAN_SHIFT);
> +#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* flag for FC=
oE offloads */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->proto=
col =3D=3D htons(ETH_P_FCOE))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0tx_flags |=3D IXGBE_TX_FLAGS_FCOE;
> --

Thanks Jon.  I think I may already have a patch in my queue with this
fix, but if I do not, I make sure to add your patch.

--=20
Cheers,
Jeff
