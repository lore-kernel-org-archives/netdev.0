From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/2] amd-xgbe: Fix possible uninitialized variable
Date: Tue, 15 Nov 2016 16:11:05 -0600
Message-ID: <20161115221104.12403.96505.stgit@tlendack-t1.amdoffice.net>
References: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <colin.king@canonical.com>, David Miller <davem@davemloft.net>,
        <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0082.outbound.protection.outlook.com ([104.47.42.82]:13747
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935038AbcKOWLN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 17:11:13 -0500
In-Reply-To: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debugfs support in the driver uses a common routine to write the
debugfs values. In this routine, if the input file position is non-zero
then the write routine will not return an error and an output parameter
will not have been set. Because an error isn't returned an uninitialized
value will be written into a register.

Fix the common write routine to return an error if the input file position
is non-zero, which will propagate back to the caller.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 0c0140d..7546b66 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -153,7 +153,7 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
 	int ret;
 
 	if (*ppos != 0)
-		return 0;
+		return -EINVAL;
 
 	if (count >= sizeof(workarea))
 		return -ENOSPC;
