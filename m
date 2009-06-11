From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 20/21] wimax: fix warning caused by not checking retval of rfkill_set_hw_state()
Date: Thu, 11 Jun 2009 14:35:57 -0700
Message-ID: <d2f4c10544231c3681f937a1e511f4780b4b39af.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756275AbZFKVgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:49 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caused by an API update. The return value can be safely ignored, as
there is notthing we can do with it.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-rfkill.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index bb102e4..70ef4df 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -113,7 +113,8 @@ void wimax_report_rfkill_hw(struct wimax_dev *wimax_dev,
 		else
 			wimax_state = WIMAX_ST_RADIO_OFF;
 
-		rfkill_set_hw_state(wimax_dev->rfkill, state == WIMAX_RF_OFF);
+		result = rfkill_set_hw_state(wimax_dev->rfkill,
+					     state == WIMAX_RF_OFF);
 
 		__wimax_state_change(wimax_dev, wimax_state);
 	}
-- 
1.6.2.3

