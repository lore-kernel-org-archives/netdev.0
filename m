From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 net-next] enic: add devcmd2
Date: Fri, 21 Aug 2015 11:40:02 -0700 (PDT)
Message-ID: <20150821.114002.1509234742678813994.davem@davemloft.net>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
	<20150817.153832.1220000969996122058.davem@davemloft.net>
	<253CF818969A9240AB2054BF91F2C2BC301A082C@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, nalreddy@cisco.com,
	ssujith@cisco.com, benve@cisco.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbHUS0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 14:26:02 -0400
In-Reply-To: <253CF818969A9240AB2054BF91F2C2BC301A082C@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Fri, 21 Aug 2015 17:19:03 +0000

> This series introduces a compile error
> drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_probe':
> drivers/net/ethernet/cisco/enic/enic_main.c:2490:3: error: label 'err_out_vnic_unregister' used but not defined
>    goto err_out_vnic_unregister;
>    ^

Thanks I'm about to push the following to fix this:

====================
[PATCH] enic: Fix build failure with SRIOV disabled.

err_out_vnic_unregister is used regardless of whether
SRIOV is enabled or not.

Reported-by: Jesse Brandeburg <jesse.brangeburg@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index cb1fdc3..3352d02 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2663,8 +2663,8 @@ err_out_disable_sriov_pp:
 		pci_disable_sriov(pdev);
 		enic->priv_flags &= ~ENIC_SRIOV_ENABLED;
 	}
-err_out_vnic_unregister:
 #endif
+err_out_vnic_unregister:
 	vnic_dev_unregister(enic->vdev);
 err_out_iounmap:
 	enic_iounmap(enic);
-- 
1.7.10.4
