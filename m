From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qlcnic: convert list_for_each to entry variant
Date: Mon, 13 May 2013 17:01:14 +0800
Message-ID: <CAPgLHd_dxz-Nh2MAtEnSBWBrpSoyUBsQaoc2Hvh7CH4hhfNQKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: rajesh.borundia@qlogic.com, shahed.shaikh@qlogic.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:65010 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab3EMJBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 05:01:15 -0400
Received: by mail-bk0-f41.google.com with SMTP id jc3so2311786bkc.14
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 02:01:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

convert list_for_each() to list_for_each_entry().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8fb836d..d7d4851 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -311,10 +311,8 @@ int qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 static void qlcnic_delete_adapter_mac(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_mac_list_s *cur;
-	struct list_head *head;
 
-	list_for_each(head, &adapter->mac_list) {
-		cur = list_entry(head, struct qlcnic_mac_list_s, list);
+	list_for_each_entry(cur, &adapter->mac_list, list) {
 		if (!memcmp(adapter->mac_addr, cur->mac_addr, ETH_ALEN)) {
 			qlcnic_sre_macaddr_change(adapter, cur->mac_addr,
 						  0, QLCNIC_MAC_DEL);
