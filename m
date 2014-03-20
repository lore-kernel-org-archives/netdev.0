From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 4/9] net: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/net/ppp/pptp.c
Date: Thu, 20 Mar 2014 20:11:56 +0530
Message-ID: <01911c3cccbcd3916e0c29854d289187507f7746.1395324808.git.monamagarwal123@gmail.com>
References: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/net/ppp/pptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 89f829f..ede899c 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -162,7 +162,7 @@ static void del_chan(struct pppox_sock *sock)
 {
 	spin_lock(&chan_lock);
 	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
-	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
+	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
 	spin_unlock(&chan_lock);
 	synchronize_rcu();
 }
-- 
1.7.9.5
