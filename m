From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 3/4] ibmveth: Checksum offload is always disabled
Date: Thu, 08 Sep 2011 10:41:05 +1000
Message-ID: <20110908004121.744925909@samba.org>
References: <20110908004102.355674129@samba.org>
Cc: netdev@vger.kernel.org
To: Santiago Leon <santil@linux.vnet.ibm.com>,
	brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com,
	mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45063 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757657Ab1IHAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 20:45:27 -0400
Content-Disposition: inline; filename=ibmveth_fix_csum.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b9367bf3ee6d (net: ibmveth: convert to hw_features) reversed
a check in ibmveth_set_csum_offload that results in checksum offload
never being enabled.

Signed-off-by: Anton Blanchard <anton@samba.org>
Cc: <stable@kernel.org> # 3.0+
---

Index: linux-build/drivers/net/ibmveth.c
===================================================================
--- linux-build.orig/drivers/net/ibmveth.c	2011-09-01 16:02:12.198726425 +1000
+++ linux-build/drivers/net/ibmveth.c	2011-09-01 16:05:37.282482851 +1000
@@ -812,7 +812,7 @@ static int ibmveth_set_csum_offload(stru
 		} else
 			adapter->fw_ipv6_csum_support = data;
 
-		if (ret != H_SUCCESS || ret6 != H_SUCCESS)
+		if (ret == H_SUCCESS || ret6 == H_SUCCESS)
 			adapter->rx_csum = data;
 		else
 			rc1 = -EIO;
