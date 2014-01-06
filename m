From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: Do not enable default port on the VEB
Date: Mon,  6 Jan 2014 04:30:26 -0800
Message-ID: <1389011436-18424-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753477AbaAFMal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:41 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Enabling the default port on the VEB causes all outgoing traffic from
virtual functions to be copied to the physical function.  The default
port is only supposed to be used if you wish to bridge the physical
function to a SW switch such as Open vSwitch or the Linux bridge. That
allows the SW switch to route traffic to VMs that are not using a
virtual function.

Eventually we'll want to implement the ndo_fdb_add, ndo_fdb_del, and
ndo_fdb_dump functions.  The ndo_fdb_add function would set the
default port on the VEB in those cases where the MAC/VLAN address
filters have overflowed.  Normally we would not want to use it.

Change-Id: I3990f0384fff2840c4e43bc0955dd0b701380852
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d0b2046..c0d7fe6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6903,7 +6903,7 @@ void i40e_veb_release(struct i40e_veb *veb)
  **/
 static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 {
-	bool is_default = (vsi->idx == vsi->back->lan_vsi);
+	bool is_default = false;
 	bool is_cloud = false;
 	int ret;
 
-- 
1.8.3.1
