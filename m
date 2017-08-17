From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/7] devlink: No need for this self-assignment
Date: Thu, 17 Aug 2017 19:09:25 +0200
Message-ID: <20170817170931.24089-2-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45629 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753386AbdHQRKw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:52 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dl_argv_handle_both() will either assign to handle_bit or error out in
which case the variable is not used by the caller.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 devlink/devlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index f9bc16c350c40..bf43e2cd5e709 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -779,7 +779,7 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 	int err;
 
 	if (o_required & DL_OPT_HANDLE && o_required & DL_OPT_HANDLEP) {
-		uint32_t handle_bit = handle_bit;
+		uint32_t handle_bit;
 
 		err = dl_argv_handle_both(dl, &opts->bus_name, &opts->dev_name,
 					  &opts->port_index, &handle_bit);
-- 
2.13.1
