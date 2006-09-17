From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/3][ATM]: potential NULL pointer dereference in clip_mkip()
Date: Sat, 16 Sep 2006 20:19:21 -0400
Message-ID: <200609170019.k8H0JLER025309@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:2217 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S964882AbWIQATf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Sep 2006 20:19:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: potential NULL pointer dereference in clip_mkip()

http://article.gmane.org/gmane.linux.kernel/445717

When re-processing received data, a struct sk_buff pointer skb may be
dereferenced after a free operation.

From: Frederik Deweerdt <deweerdt@free.fr>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 87409562aeed5fb2b85dc2f9bddca0a1bbde8c37
tree 0885b8bd2b8881201de422877abd8979861c44de
parent fc6b6284e9383bd8d9fd95210fbc5e3c54ccc65d
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:55:01 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:55:01 -0400

 net/atm/clip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 7ce7bfe..0dfa3a4 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -500,9 +500,9 @@ static int clip_mkip(struct atm_vcc *vcc
 		} else {
 			unsigned int len = skb->len;
 
-			clip_push(vcc, skb);
 			PRIV(skb->dev)->stats.rx_packets--;
 			PRIV(skb->dev)->stats.rx_bytes -= len;
+			clip_push(vcc, skb);
 		}
 	return 0;
 }
