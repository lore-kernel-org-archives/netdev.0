From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Use skb_is_gso_v6(skb) instead of
 accessing the skb_shinfo(skb) directly
Date: Sat, 27 Nov 2010 10:53:45 +0100
Message-ID: <1290851625.2794.17.camel@edumazet-laptop>
References: <1290612078.27220.2.camel@lb-tlvb-vladz>
	 <1290678762.18389.1.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev list <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f66.google.com ([74.125.82.66]:60905 "EHLO
	mail-ww0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab0K0Jxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 04:53:51 -0500
Received: by wwb34 with SMTP id 34so477172wwb.1
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 01:53:50 -0800 (PST)
In-Reply-To: <1290678762.18389.1.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 novembre 2010 =C3=A0 11:52 +0200, Vladislav Zolotarov a =C3=
=A9crit :
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_=
cmn.c
> index 94d5f59..fa8e9ee 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -1695,7 +1695,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x =
*bp, struct sk_buff *skb)
>  	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
>  		rc |=3D (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
> =20
> -	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> +	else if (skb_is_gso_v6(skb))
>  		rc |=3D (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
> =20
>  	return rc;

May I ask why ?

This seems not consistent with the previous block.

Either you also add a skb_is_gso_v4(skb) helper, or let the code as is,
maybe reordering the flags ?

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index 94d5f59..514aad6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1693,10 +1693,9 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *=
bp, struct sk_buff *skb)
 	}
=20
 	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-		rc |=3D (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
-
+		rc |=3D XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP;
 	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-		rc |=3D (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
+		rc |=3D XMIT_GSO_V6 | XMIT_CSUM_V6 | XMIT_CSUM_TCP;
=20
 	return rc;
 }


