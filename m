From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:36:35 +0200
Message-ID: <1273502195.2221.4.camel@edumazet-laptop>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
	 <1273222403.2261.26.camel@edumazet-laptop>  <4BE81793.3060905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62186 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab0EJOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:36:42 -0400
Received: by bwz19 with SMTP id 19so1804765bwz.21
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 07:36:40 -0700 (PDT)
In-Reply-To: <4BE81793.3060905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 16:26 +0200, Patrick McHardy a =C3=A9crit :

>=20
> Is the intention just to avoid accounting the packet as dropped?
> That seems fine to me since in case of NET_XMIT_CN its actually
> not the currently transmitted packet that was dropped.
>=20
> But part of the intention of the above mentioned patch was actually
> to inform higher layers of congestion so they can take action if
> desired, which would be defeated by this patch.
>=20

I see, so maybe we want following patch instead ?

(letting NET_XMIT_CN be given to caller, but accounting current packet
as transmitted ?)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b5249c5..55be908 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -327,7 +327,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct =
sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
-	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
 	} else
@@ -353,7 +353,7 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit=
(struct sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
-	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
 	} else


