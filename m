From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] flow_dissector: Pre-initialize ip_proto in __skb_flow_dissect()
Date: Thu, 25 Jun 2015 15:10:32 +0200
Message-ID: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:53185 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbFYNKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/core/flow_dissector.c: In function =E2=80=98__skb_flow_dissect=E2=80=
=99:
net/core/flow_dissector.c:132: warning: =E2=80=98ip_proto=E2=80=99 may =
be used uninitialized in this function

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
This may be a false positive, but the state machine in
__skb_flow_dissect() is a bit hard to follow.
As I believe it is controlled by a packet received from the network, th=
e
only safe thing to do is to pre-initialize ip_proto.
---
 net/core/flow_dissector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 476e5dda59e19822..2a834c6179b9973e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -129,7 +129,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_keyid *key_keyid;
-	u8 ip_proto;
+	u8 ip_proto =3D 0;
=20
 	if (!data) {
 		data =3D skb->data;
--=20
1.9.1
