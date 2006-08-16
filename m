From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] spectrum_cs: Fix incorrect use of pcmcia_dev_present()
Date: Tue, 15 Aug 2006 20:42:20 -0400
Message-ID: <20060816004220.2876.90069.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:18150
	"EHLO smtp.roinet.com") by vger.kernel.org with ESMTP
	id S1750744AbWHPAm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 20:42:26 -0400
Received: from dv.roinet.com (192.168.1.21 [192.168.1.21])
    by smtp.roinet.com with SMTP;
    for netdev@vger.kernel.org;
    Tue, 15 Aug 2006 20:46:34 -0400 (EDT)
    (envelope-from proski@gnu.org)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

This bug was introduced during the PCMCIA API conversion and broke
spectrum_cs completely.

Tracked down by Fredrik Tolf <fredrik@dolda2000.com>

Signed-off-by: Pavel Roskin <proski@gnu.org>

---
This patch should go to 2.6.18 and 2.6.17.y.
---

 drivers/net/wireless/spectrum_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index 7f78b78..bcc7038 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -242,7 +242,7 @@ spectrum_reset(struct pcmcia_device *lin
 	u_int save_cor;
 
 	/* Doing it if hardware is gone is guaranteed crash */
-	if (pcmcia_dev_present(link))
+	if (!pcmcia_dev_present(link))
 		return -ENODEV;
 
 	/* Save original COR value */
