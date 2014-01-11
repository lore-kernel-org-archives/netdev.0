From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] net: qlcnic: fix warning for incorrect type
 in argument
Date: Sat, 11 Jan 2014 16:23:35 +0800
Message-ID: <52D0FF87.4090806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:53317 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbaAKIYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 03:24:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 6878f79a8b71e8c7b0587a1185584f54fd31f185
(net: qlcnic: slight optimization of addr compare)
cause a warning "sparse: incorrect type in argument 2
(different type sizes)", so fix it.

I think julia will convert ether_addr_equal to ether_addr_equal_64bits later.

Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 6373f60..24714de 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -346,7 +346,7 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 	head = &(adapter->fhash.fhead[hindex]);
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
-		if (ether_addr_equal(tmp_fil->faddr, &src_addr) &&
+		if (ether_addr_equal(tmp_fil->faddr, (u8 *)&src_addr) &&
 		    tmp_fil->vlan_id == vlan_id) {
 			if (jiffies > (QLCNIC_READD_AGE * HZ + tmp_fil->ftime))
 				qlcnic_change_filter(adapter, &src_addr,
-- 
1.8.0
