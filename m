From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] e1000e: remove EEE module parameter
Date: Tue, 29 Jun 2010 21:12:52 -0700
Message-ID: <20100630041249.8652.67388.stgit@localhost.localdomain>
References: <20100630040959.8652.31147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:52356 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978Ab0F3ENK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 00:13:10 -0400
In-Reply-To: <20100630040959.8652.31147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

As requested by Dave Miller.  A follow-on set of patches will allow for
ethtool to enable/disable the feature instead.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/param.c |   28 ----------------------------
 1 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 593251c..34aeec1 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -161,15 +161,6 @@ E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lea
 E1000_PARAM(CrcStripping, "Enable CRC Stripping, disable if your BMC needs " \
                           "the CRC");
 
-/*
- * Enable/disable EEE (a.k.a. IEEE802.3az)
- *
- * Valid Range: 0, 1
- *
- * Default Value: 1
- */
-E1000_PARAM(EEE, "Enable/disable on parts that support the feature");
-
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -486,23 +477,4 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			}
 		}
 	}
-	{ /* EEE for parts supporting the feature */
-		static const struct e1000_option opt = {
-			.type = enable_option,
-			.name = "EEE Support",
-			.err  = "defaulting to Enabled",
-			.def  = OPTION_ENABLED
-		};
-
-		if (adapter->flags2 & FLAG2_HAS_EEE) {
-			/* Currently only supported on 82579 */
-			if (num_EEE > bd) {
-				unsigned int eee = EEE[bd];
-				e1000_validate_option(&eee, &opt, adapter);
-				hw->dev_spec.ich8lan.eee_disable = !eee;
-			} else {
-				hw->dev_spec.ich8lan.eee_disable = !opt.def;
-			}
-		}
-	}
 }

