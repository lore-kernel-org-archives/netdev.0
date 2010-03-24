From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igb: only use vlan_gro_receive if vlans are registered
Date: Wed, 24 Mar 2010 06:50:37 +0100
Message-ID: <1269409837.2915.48.camel@edumazet-laptop>
References: <20100324043517.32036.81274.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38892 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab0CXFum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 01:50:42 -0400
Received: by bwz1 with SMTP id 1so2551436bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 22:50:41 -0700 (PDT)
In-Reply-To: <20100324043517.32036.81274.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 21:35 -0700, Jeff Kirsher a =C3=A9crit :
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> This change makes it so that vlan_gro_receive is only used if vlans h=
ave been
> registered to the adapter structure.  Previously we were just sending=
 all vlan
> tagged frames in via this function but this results in a null pointer
> dereference when vlans are not registered.
>=20

This patch fixes bugzilla entry 15582

See http://bugzilla.kernel.org/show_bug.cgi?id=3D15582

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

>  drivers/net/igb/igb_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index e72760c..01c65c7 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -5102,7 +5102,7 @@ static void igb_receive_skb(struct igb_q_vector=
 *q_vector,
>  {
>  	struct igb_adapter *adapter =3D q_vector->adapter;
> =20
> -	if (vlan_tag)
> +	if (vlan_tag && adapter->vlgrp)
>  		vlan_gro_receive(&q_vector->napi, adapter->vlgrp,
>  		                 vlan_tag, skb);
>  	else
>=20
> --



