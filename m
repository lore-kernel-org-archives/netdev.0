From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH ipsec] xfrm: properly handle invalid states as an error
Date: Wed, 22 May 2013 14:40:47 +0300
Message-ID: <1369222847-8542-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Li RongQing <roy.qing.li@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:49590 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799Ab3EVLj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:39:28 -0400
Received: by mail-ee0-f45.google.com with SMTP id l10so1061305eei.4
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:39:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error exit path needs err explicitly set. Otherwise it
returns success and the only caller, xfrm_output_resume(),
would oops in skb_dst(skb)->ops derefence as skb_dst(skb) is
NULL.

Bug introduced in commit bb65a9cb (xfrm: removes a superfluous
check and add a statistic).

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Li RongQing <roy.qing.li@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
Should go also to 3.9-stable.

 net/xfrm/xfrm_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index bcfda89..0cf003d 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -64,6 +64,7 @@ static int xfrm_output_one(struct sk_buff *skb, int e=
rr)
=20
 		if (unlikely(x->km.state !=3D XFRM_STATE_VALID)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
+			err =3D -EINVAL;
 			goto error;
 		}
=20
--=20
1.8.2.3
