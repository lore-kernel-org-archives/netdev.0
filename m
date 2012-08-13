From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/16] qlcnic: guard __vlan_find_dev_deep() by rcu_read_lock
Date: Mon, 13 Aug 2012 17:27:08 +0200
Message-ID: <1344871635-1052-10-git-send-email-jiri@resnulli.us>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rcu_read_lock was missing here

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 212c121..9eadf17 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -4425,12 +4425,14 @@ qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 
 	qlcnic_config_indev_addr(adapter, netdev, event);
 
+	rcu_read_lock();
 	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
 		dev = __vlan_find_dev_deep(netdev, vid);
 		if (!dev)
 			continue;
 		qlcnic_config_indev_addr(adapter, dev, event);
 	}
+	rcu_read_unlock();
 }
 
 static int qlcnic_netdev_event(struct notifier_block *this,
-- 
1.7.10.4
