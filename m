From: gfree.wind@vip.163.com
Subject: [PATCH net-next] ppp: Destroy the mutex when cleanup
Date: Tue, 31 Oct 2017 18:25:37 +0800
Message-ID: <1509445537-39319-1-git-send-email-gfree.wind@vip.163.com>
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        Gao Feng <gfree.wind@vip.163.com>
To: paulus@samba.org, davem@davemloft.net
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <gfree.wind@vip.163.com>

The mutex_destroy only makes sense when enable DEBUG_MUTEX. For the
good readbility, it's better to invoke it in exit func when the init
func invokes mutex_init.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 drivers/net/ppp/ppp_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index af7f93e..4489133 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -960,6 +960,7 @@ static __net_exit void ppp_exit_net(struct net *net)
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
 
+	mutex_destroy(&pn->all_ppp_mutex);
 	idr_destroy(&pn->units_idr);
 }
 
-- 
1.9.1


