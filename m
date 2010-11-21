From: Joe Perches <joe@perches.com>
Subject: [PATCH 35/62] qlcnic: Use static const
Date: Sat, 20 Nov 2010 18:38:36 -0800
Message-ID: <9078bfbb29939ad87bc33f2873c240a01ed78c6a.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1692 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792Ab0KUCkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:16 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  12250	  16443	   2824	  31517	   7b1d	drivers/net/qlcnic/qlcnic_hw.o.new
  12312	  16443	   2824	  31579	   7b5b	drivers/net/qlcnic/qlcnic_hw.o.old

Changed qlcnic_nic_add_mac to take a const u8 *.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 7a47a2a..691e0d1 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -398,7 +398,7 @@ qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
 	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 }
 
-static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, u8 *addr)
+static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr)
 {
 	struct list_head *head;
 	struct qlcnic_mac_list_s *cur;
@@ -432,7 +432,9 @@ void qlcnic_set_multi(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
-	u8 bcast_addr[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+	static const u8 bcast_addr[ETH_ALEN] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
 	u32 mode = VPORT_MISS_MODE_DROP;
 
 	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
@@ -638,10 +640,11 @@ int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
 	u64 word;
 	int i, rv;
 
-	const u64 key[] = { 0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
-			0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
-			0x255b0ec26d5a56daULL };
-
+	static const u64 key[] = {
+		0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
+		0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
+		0x255b0ec26d5a56daULL
+	};
 
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-- 
1.7.3.2.245.g03276.dirty

