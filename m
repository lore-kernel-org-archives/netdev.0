From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40evf: don't use RESETTING state during reinit
Date: Thu, 29 May 2014 08:10:15 -0700
Message-ID: <1401376216-12531-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55978 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535AbaE2PKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:40 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The RESETTING state means that a Catastrophic Hardware Bad Thing is
happening and the driver need to tiptoe around and not use the admin
queue or registers or anything like that.

On the other hand, a reinit is no big deal and we can use the admin
queue, and we should. So don't set the state to RESETTING here.

This fixes a Tx hang and FW crash that happens after setting the MTU on
a VF.

Change-ID: I3e6191edbd6a93958a1f1bd1d41a5c2d17474d41
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 23c9ff6..632c2b3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1844,8 +1844,6 @@ void i40evf_reinit_locked(struct i40evf_adapter *adapter)
 
 	WARN_ON(in_interrupt());
 
-	adapter->state = __I40EVF_RESETTING;
-
 	i40evf_down(adapter);
 
 	/* allocate transmit descriptors */
-- 
1.9.3
