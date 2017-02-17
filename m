From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/7] nfp: return nfp_rtsym_read_le() errors correctly
Date: Fri, 17 Feb 2017 14:00:26 -0800
Message-ID: <20170217220027.189992-7-jakub.kicinski@netronome.com>
References: <20170217220027.189992-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36349 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934994AbdBQWBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 17:01:16 -0500
Received: by mail-pg0-f41.google.com with SMTP id v184so18590155pgv.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 14:01:15 -0800 (PST)
In-Reply-To: <20170217220027.189992-1-jakub.kicinski@netronome.com>
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
