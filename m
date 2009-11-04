From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 03/12] wimax: indicate initial SW rfkill state is "blocked"
Date: Wed,  4 Nov 2009 13:39:39 -0800
Message-ID: <c29eaf3faef7547ba72355bac44e9ca6ffdaee39.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:14133 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758253AbZKDVlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:52 -0500
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The WiMAX stack assumes that all WiMAX devices are SW OFF when they
are initialized. The recent changes in the RFKILL stack thus cause an
initial call after rfkill_register(), because by default, rfkill
considers devices to be SW ON upon registration.

So call rfkill_init_sw_state() to set it to SW OFF so
rfkill_register() doesn't do that unnecessary step.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-rfkill.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 70ef4df..40e1210 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -355,6 +355,7 @@ int wimax_rfkill_add(struct wimax_dev *wimax_dev)
 
 	wimax_dev->rfkill = rfkill;
 
+	rfkill_init_sw_state(rfkill, 1);
 	result = rfkill_register(wimax_dev->rfkill);
 	if (result < 0)
 		goto error_rfkill_register;
-- 
1.6.2.5

