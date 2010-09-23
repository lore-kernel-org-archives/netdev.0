From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] igb: clear VF_PROMISC bits instead of
	setting all other bits
Date: Wed, 22 Sep 2010 20:56:20 -0700
Message-ID: <20100923035538.11511.16233.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:56846
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752985Ab0IWD4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:56:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects an issue in which we were setting all flag bits except
for promisc instead of clearing the promisc bits due to the incorrect use
of an |= instead of an &=.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c4d861b..fd922e7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4659,12 +4659,13 @@ static int igb_set_vf_promisc(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 	u32 vmolr = rd32(E1000_VMOLR(vf));
 	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
 
-	vf_data->flags |= ~(IGB_VF_FLAG_UNI_PROMISC |
+	vf_data->flags &= ~(IGB_VF_FLAG_UNI_PROMISC |
 	                    IGB_VF_FLAG_MULTI_PROMISC);
 	vmolr &= ~(E1000_VMOLR_ROPE | E1000_VMOLR_ROMPE | E1000_VMOLR_MPME);
 
 	if (*msgbuf & E1000_VF_SET_PROMISC_MULTICAST) {
 		vmolr |= E1000_VMOLR_MPME;
+		vf_data->flags |= IGB_VF_FLAG_MULTI_PROMISC;
 		*msgbuf &= ~E1000_VF_SET_PROMISC_MULTICAST;
 	} else {
 		/*

