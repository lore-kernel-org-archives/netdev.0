From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 6/7] nfp: return nfp_rtsym_read_le() errors correctly
Date: Sun, 19 Feb 2017 11:58:13 -0800
Message-ID: <20170219195814.40471-7-jakub.kicinski@netronome.com>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        kubakici@wp.pl, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34829 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdBST6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 14:58:25 -0500
Received: by mail-pg0-f48.google.com with SMTP id b129so9787375pgc.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 11:58:25 -0800 (PST)
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_rtsym_read_le() has an out parameter for error codes.
We have to use that instead of returning errors directly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
index c659b1d999be..0e3870ecfb8c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
@@ -269,8 +269,10 @@ u64 nfp_rtsym_read_le(struct nfp_cpp *cpp, const char *name, int *error)
 	int err;
 
 	sym = nfp_rtsym_lookup(cpp, name);
-	if (!sym)
-		return -ENOENT;
+	if (!sym) {
+		err = -ENOENT;
+		goto exit;
+	}
 
 	id = NFP_CPP_ISLAND_ID(sym->target, NFP_CPP_ACTION_RW, 0, sym->domain);
 
@@ -294,7 +296,7 @@ u64 nfp_rtsym_read_le(struct nfp_cpp *cpp, const char *name, int *error)
 		err = 0;
 	else if (err >= 0)
 		err = -EIO;
-
+exit:
 	if (error)
 		*error = err;
 
-- 
2.11.0
