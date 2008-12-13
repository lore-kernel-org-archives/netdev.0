From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/11] nf/dccp: merge errorpaths
Date: Sat, 13 Dec 2008 21:17:50 +0200
Message-ID: <12291958721873-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711089-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958711225-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958713600-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958712305-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958712963-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195872202-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958721148-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12291958721188-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41228 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYLMTR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:57 -0500
In-Reply-To: <12291958721188-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_dccp.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index e5d3e86..0989f29 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -45,10 +45,8 @@ dccp_find_option(u_int8_t option,
 	unsigned int optlen =3D dh->dccph_doff*4 - __dccp_hdr_len(dh);
 	unsigned int i;
=20
-	if (dh->dccph_doff * 4 < __dccp_hdr_len(dh)) {
-		*hotdrop =3D true;
-		return false;
-	}
+	if (dh->dccph_doff * 4 < __dccp_hdr_len(dh))
+		goto invalid;
=20
 	if (!optlen)
 		return false;
@@ -57,9 +55,7 @@ dccp_find_option(u_int8_t option,
 	op =3D skb_header_pointer(skb, protoff + optoff, optlen, dccp_optbuf)=
;
 	if (op =3D=3D NULL) {
 		/* If we don't have the whole header, drop packet. */
-		spin_unlock_bh(&dccp_buflock);
-		*hotdrop =3D true;
-		return false;
+		goto partial;
 	}
=20
 	for (i =3D 0; i < optlen; ) {
@@ -76,6 +72,12 @@ dccp_find_option(u_int8_t option,
=20
 	spin_unlock_bh(&dccp_buflock);
 	return false;
+
+partial:
+	spin_unlock_bh(&dccp_buflock);
+invalid:
+	*hotdrop =3D true;
+	return false;
 }
=20
=20
--=20
1.5.2.2

