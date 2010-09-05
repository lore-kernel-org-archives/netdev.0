From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 8/8] drivers/net/wireless/iwlwifi/iwl-agn.c: Fix return value from an unsigned function
Date: Sun,  5 Sep 2010 21:00:26 +0200
Message-ID: <1283713226-8429-9-git-send-email-julia@diku.dk>
References: <1283713226-8429-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Reinette Chatre <reinette.chatre@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35493 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454Ab0IES7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Sep 2010 14:59:39 -0400
In-Reply-To: <1283713226-8429-1-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function has an unsigned return type, but returns a negative constant
to indicate an error condition.  Another error condition in the same
function is indicated by returning 0, and indeed the only call to the
function checks for 0 to detect errors, so the return of a negative value
it converted to a return of 0.

A sematic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@exists@
identifier f;
constant C;
@@

 unsigned f(...)
 { <+...
*  return -C;
 ...+> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/iwlwifi/iwl-agn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index ad0e67f..86b55c2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -369,7 +369,7 @@ static unsigned int iwl_hw_get_beacon_cmd(struct iwl_priv *priv,
 
 	if (!priv->beacon_ctx) {
 		IWL_ERR(priv, "trying to build beacon w/o beacon context!\n");
-		return -EINVAL;
+		return 0;
 	}
 
 	/* Initialize memory */

