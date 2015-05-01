From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH 3/3] ixgbevf: Use dev_kfree_skb_any in xmit path,
 not dev_kfree_skb
Date: Fri, 01 May 2015 10:34:50 -0700
Message-ID: <20150501173450.1029.86224.stgit@ahduyck-vm-fedora22>
References: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, davem@davemloft.net
To: netdev@vger.kernel.org, nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbbEARfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2015 13:35:53 -0400
In-Reply-To: <20150501173049.1029.54421.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With netpoll making use of the transmit function it is possible for the
ndo_start_xmit function to be called with irqs disabled.  As such we need
to use dev_kfree_skb_any in the Tx cleanup path for frames that are
dropped.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index cca8936f2fc3..acfa05154436 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3584,7 +3584,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	u8 *dst_mac = skb_header_pointer(skb, 0, 0, NULL);
 
 	if (!dst_mac || is_link_local_ether_addr(dst_mac)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
