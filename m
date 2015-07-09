From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] net: wireless: reduce log level of CRDA related messages
Date: Thu,  9 Jul 2015 15:35:15 +0200
Message-ID: <1436448915-31724-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:49841 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752946AbbGINfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 09:35:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a basic Linux userspace, the messages "Calling CRDA to update
world regulatory domain" appears 10 times after boot every second or
so, followed by a final "Exceeded CRDA call max attempts. Not calling
CRDA". For those of us not having the corresponding userspace parts,
having those messages repeatedly displayed at boot time is a bit
annoying, so this commit reduces their log level to pr_debug().

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 net/wireless/reg.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index d359e06..29134c8 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -544,15 +544,15 @@ static int call_crda(const char *alpha2)
 	reg_regdb_query(alpha2);
 
 	if (reg_crda_timeouts > REG_MAX_CRDA_TIMEOUTS) {
-		pr_info("Exceeded CRDA call max attempts. Not calling CRDA\n");
+		pr_debug("Exceeded CRDA call max attempts. Not calling CRDA\n");
 		return -EINVAL;
 	}
 
 	if (!is_world_regdom((char *) alpha2))
-		pr_info("Calling CRDA for country: %c%c\n",
+		pr_debug("Calling CRDA for country: %c%c\n",
 			alpha2[0], alpha2[1]);
 	else
-		pr_info("Calling CRDA to update world regulatory domain\n");
+		pr_debug("Calling CRDA to update world regulatory domain\n");
 
 	return kobject_uevent_env(&reg_pdev->dev.kobj, KOBJ_CHANGE, env);
 }
-- 
2.4.5
