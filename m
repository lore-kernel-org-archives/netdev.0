From: hannemann@nets.rwth-aachen.de
Subject: [PATCH] iproute2: Avoid rounding errors for 100%.
Date: Tue, 03 Nov 2009 16:38:14 +0100
Message-ID: <1257262694-16985-1-git-send-email-hannemann@nets.rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:61243 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013AbZKCQIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 11:08:44 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KSJ00EWGI4NNV60@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 03 Nov 2009 16:38:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

We noticed that a netem reorder percentage of 100% will still get packets reordered.
This patch fixes that.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
---
 tc/tc_util.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index fe2c7eb..2641f2e 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -363,8 +363,10 @@ int get_percent(__u32 *percent, const char *str)
 		return -1;
 	if (*p && strcmp(p, "%"))
 		return -1;
-
-	*percent = (unsigned) rint(per * max_percent_value);
+	if (per == 1.)
+		*percent = max_percent_value;
+	else
+		*percent = (unsigned) rint(per * max_percent_value);
 	return 0;
 }
 
-- 
1.6.3.3

