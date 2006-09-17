From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/3][ATM]: [he] don't hold the device lock when upcalling
Date: Sat, 16 Sep 2006 20:19:02 -0400
Message-ID: <200609170019.k8H0J2eS025296@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:937 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S964881AbWIQATQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Sep 2006 20:19:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [he] don't hold the device lock when upcalling

This can create a deadlock/lock ordering problem with other layers that
want to use the transmit (or other) path of the card at that time.

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit fc6b6284e9383bd8d9fd95210fbc5e3c54ccc65d
tree cfb6beef3334433e331d27f453d0c3901bd7c5c2
parent c0361a8558796e5af9c5d4e8d4900e4dc44c2e4e
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:49:53 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:49:53 -0400

 drivers/atm/he.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 4598b1f..55ca7d8 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1928,7 +1928,9 @@ #endif
 #ifdef notdef
 		ATM_SKB(skb)->vcc = vcc;
 #endif
+		spin_unlock(&he_dev->global_lock);
 		vcc->push(vcc, skb);
+		spin_lock(&he_dev->global_lock);
 
 		atomic_inc(&vcc->stats->rx);
 
