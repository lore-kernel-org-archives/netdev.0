From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: add support for supporting 10000baseT
Date: Wed, 07 Nov 2007 08:24:20 -0800
Message-ID: <20071107162420.5102.26358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41617 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbXKGQYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:24:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

there is missing support in ethtool for reporting 10000baseT
as SUPPORTED_10000baseT_Full.  The code seems to be half
implemented because the "advertising" field has the implementation.

this patch just adds it for supported reporting.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6c7a2e3..888be57 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -725,6 +725,13 @@ static void dump_supported(struct ethtool_cmd *ep)
 	if (mask & SUPPORTED_2500baseX_Full) {
 		did1++; fprintf(stdout, "2500baseX/Full ");
 	}
+	if (did1 && (mask & SUPPORTED_10000baseT_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & SUPPORTED_10000baseT_Full) {
+		did1++; fprintf(stdout, "10000baseT/Full ");
+	}
 	fprintf(stdout, "\n");
 
 	fprintf(stdout, "	Supports auto-negotiation: ");
