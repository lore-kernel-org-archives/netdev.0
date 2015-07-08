From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] mwifiex: drop condition with no effect
Date: Wed,  8 Jul 2015 16:15:02 +0200
Message-ID: <1436364902-28943-1-git-send-email-hofrat@osadl.org>
Cc: Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:53019 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758270AbbGHOXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 10:23:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

scanning for trivial bug-patters with coccinelle spatches returned:
./drivers/net/wireless/mwifiex/sta_cmdresp.c:895
        WARNING: condition with no effect (if branch == else)

originally added in 'commit d8d2f19feb16 ("mwifiex: silence TDLS link
delete failure for nonexistent link")' with dev_dbg/dev_err (though
with the same message) to differentiate severity and then in 'commit
acebe8c10a6e ("mwifiex: change dbg print func to mwifiex_dbg")' all
dev_dbg,dev_warn and dev_err got converted to mwifiex_dbg which should
thus probably drop this if/else as well.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

If dropping the if/else is not the right thing to do then commit 
acebe8c10a6e "mwifiex: change dbg print func to mwifiex_dbg" probably
needs a review as well.

Patch was compile tested with x86_64_defconfig + CONFIG_MWIFIEX=m

Patch is against 4.2-rc1 (localversion-next is -next-20150708)

 drivers/net/wireless/mwifiex/sta_cmdresp.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index b645884..e58f900 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -892,14 +892,9 @@ static int mwifiex_ret_tdls_oper(struct mwifiex_private *priv,
 	switch (action) {
 	case ACT_TDLS_DELETE:
 		if (reason) {
-			if (!node || reason == TDLS_ERR_LINK_NONEXISTENT)
-				mwifiex_dbg(priv->adapter, ERROR,
-					    "TDLS link delete for %pM failed: reason %d\n",
-					    cmd_tdls_oper->peer_mac, reason);
-			else
-				mwifiex_dbg(priv->adapter, ERROR,
-					    "TDLS link delete for %pM failed: reason %d\n",
-					    cmd_tdls_oper->peer_mac, reason);
+			mwifiex_dbg(priv->adapter, ERROR,
+				    "TDLS link delete for %pM failed: reason %d\n",
+				    cmd_tdls_oper->peer_mac, reason);
 		} else {
 			mwifiex_dbg(priv->adapter, MSG,
 				    "TDLS link delete for %pM successful\n",
-- 
1.7.10.4
