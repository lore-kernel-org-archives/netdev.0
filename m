From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 01/14] e1000: The user-supplied itr setting needs the lower
	2 bits masked off
Date: Fri, 15 Dec 2006 10:29:31 +0100
Message-ID: <1166174971.3365.110.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751485AbWLOKAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:55 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gi35006131
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:44 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9ghev006129
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:43 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: The user-supplied itr setting needs the lower 2 bits masked off
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The lower 2 bits of a user-supplied itr setting (via ethtool) need to be
masked off: These lower two bits are used as control bits.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

---
 drivers/net/e1000/e1000_param.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/e1000/e1000_param.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_param.c
+++ linux-2.6/drivers/net/e1000/e1000_param.c
@@ -487,7 +487,9 @@ e1000_check_options(struct e1000_adapter
 				e1000_validate_option(&adapter->itr, &opt,
 				        adapter);
 				/* save the setting, because the dynamic bits change itr */
-				adapter->itr_setting = adapter->itr;
+				/* clear the lower two bits because they are
+				 * used as control */
+				adapter->itr_setting = adapter->itr & ~3;
 				break;
 			}
 		} else {

