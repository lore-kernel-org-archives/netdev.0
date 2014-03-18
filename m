From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 4/9] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
Date: Wed, 19 Mar 2014 04:15:44 +0530
Message-ID: <dfae0194a7fa12d09826ec79bbd7cecd132c7f8d.1395182132.git.monamagarwal123@gmail.com>
References: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395182132.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a526cbfdba8a9a3380b685d34b4ee7ce52163d57.1395182132.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395182132.git.monamagarwal123@gmail.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
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
