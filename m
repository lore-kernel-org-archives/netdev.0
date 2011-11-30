From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 1/3] caif: Allow cfpkt_extr_head to process empty message
Date: Wed, 30 Nov 2011 20:22:46 +0100
Message-ID: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48191 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab1K3TXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 14:23:10 -0500
Received: by eeuu47 with SMTP id u47so579578eeu.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 11:23:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow NULL pointer in cfpkt_extr_head in order to
skip past header data.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfpkt_skbuff.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index df08c47..de53907 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -144,7 +144,8 @@ int cfpkt_extr_head(struct cfpkt *pkt, void *data, =
u16 len)
 	}
 	from =3D skb_pull(skb, len);
 	from -=3D len;
-	memcpy(data, from, len);
+	if (data)
+		memcpy(data, from, len);
 	return 0;
 }
=20
--=20
1.7.0.4
