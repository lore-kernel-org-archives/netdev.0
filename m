From: Joe Perches <joe@perches.com>
Subject: [PATCH] i40e: Fix possible memory leak in i40e_dbg_dump_desc
Date: Sat, 06 Dec 2014 06:03:21 -0800
Message-ID: <1417874601.31745.21.camel@perches.com>
References: <20141206134513.GD4963@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kbuild@01.org, Shannon Nelson <shannon.nelson@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev <netdev@vger.kernel.org>, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0058.hostedemail.com ([216.40.44.58]:34575 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751167AbaLFODZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 09:03:25 -0500
In-Reply-To: <20141206134513.GD4963@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't notice that return in the code, fix it by
adding a goto out instead to free the memory.

Fixes:

> New smatch warnings:
> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:832 i40e_dbg_dump_desc() warn: possible memory leak of 'ring'

Signed-off-by: Joe Perches <joe@perches.com>
Noticed-by: Dan Carpenter <dan.carpenter@oracle.com> (go smatch)
---

Jeff Kirsher can legitimately give me a hard time now...
Thanks Dan.

 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 433a558..cb0de45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -829,7 +829,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		if (desc_n >= ring->count || desc_n < 0) {
 			dev_info(&pf->pdev->dev,
 				 "descriptor %d not found\n", desc_n);
-			return;
+			goto out;
 		}
 		if (!is_rx_ring) {
 			txd = I40E_TX_DESC(ring, desc_n);
@@ -855,6 +855,8 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 	} else {
 		dev_info(&pf->pdev->dev, "dump desc rx/tx <vsi_seid> <ring_id> [<desc_n>]\n");
 	}
+
+out:
 	kfree(ring);
 }
 
