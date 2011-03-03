From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] bonding: COW before overwriting the destination
 MAC address
Date: Thu, 03 Mar 2011 07:45:42 +0100
Message-ID: <1299134742.2456.1.camel@edumazet-laptop>
References: <1299126321-9300-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54091 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab1CCGps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 01:45:48 -0500
Received: by wyg36 with SMTP id 36so760125wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 22:45:47 -0800 (PST)
In-Reply-To: <1299126321-9300-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 12:25 +0800, Changli Gao a =C3=A9crit :
> When there is a ptype handler holding a clone of this skb, whose
> destination MAC addresse is overwritten, the owner of this handler ma=
y
> get a corrupted packet.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  drivers/net/bonding/bond_main.c |    5 +++++
>  1 file changed, 5 insertions(+)
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 912b416..211be52 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1513,6 +1513,11 @@ static struct sk_buff *bond_handle_frame(struc=
t sk_buff *skb)
>  	    skb->pkt_type =3D=3D PACKET_HOST) {
>  		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> =20
> +		if (unlikely(skb_cow_head(skb,
> +					  skb->data - skb_mac_header(skb)))) {
> +			kfree_skb(skb);
> +			return NULL;
> +		}
>  		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
>  	}
> =20

This seems buggy.

dest points to old skb head content.



