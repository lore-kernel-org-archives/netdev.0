From: Colin King <colin.king@canonical.com>
Subject: [PATCH] softingcs: ret is never non-zero, so remove non-zero check and -ENODEV return
Date: Wed, 11 Jan 2017 15:02:38 +0000
Message-ID: <20170111150238.19845-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The error return ret is never zero in the error handling path in
softingcs_probe, so the check for non-zero and returning -ENODEV
is logically dead code and hence redundant.  Remove it and just
return ret.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/can/softing/softing_cs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/softing/softing_cs.c b/drivers/net/can/softing/softing_cs.c
index cdc0c74..4d44928 100644
--- a/drivers/net/can/softing/softing_cs.c
+++ b/drivers/net/can/softing/softing_cs.c
@@ -310,7 +310,7 @@ static int softingcs_probe(struct pcmcia_device *pcmcia)
 pcmcia_failed:
 	pcmcia_disable_device(pcmcia);
 	pcmcia->priv = NULL;
-	return ret ?: -ENODEV;
+	return ret;
 }
 
 static const struct pcmcia_device_id softingcs_ids[] = {
-- 
2.10.2
