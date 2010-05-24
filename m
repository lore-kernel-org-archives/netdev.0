From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH net-2.6] be2net: Bug fix in init code in probe
Date: Mon, 24 May 2010 16:50:47 +0530
Message-ID: <20100524112033.GA3666@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:33003 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756162Ab0EXL32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 07:29:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI function reset needs to invoked after fw init ioctl is issued.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 058d7f9..1c79c20 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2487,10 +2487,6 @@ static int __devinit be_probe(struct pci
 		status = be_cmd_POST(adapter);
 		if (status)
 			goto ctrl_clean;
-
-		status = be_cmd_reset_function(adapter);
-		if (status)
-			goto ctrl_clean;
 	}
 
 	/* tell fw we're ready to fire cmds */
@@ -2498,6 +2494,12 @@ static int __devinit be_probe(struct pci
 	if (status)
 		goto ctrl_clean;
 
+	if (be_physfn(adapter)) {
+		status = be_cmd_reset_function(adapter);
+		if (status)
+			goto ctrl_clean;
+	}
+
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
-- 
1.4.0

