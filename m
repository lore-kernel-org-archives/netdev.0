From: kan.liang@intel.com
Subject: [RFC V2 PATCH 23/25] net/netpolicy: optimize for queue pair
Date: Wed, 31 Dec 2014 20:39:12 -0500
Message-ID: <1420076354-4861-24-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Some drivers like i40e driver does not support separate Tx and Rx queues
as channels. Using Rx queue to stand for the channels, if queue_pair is
set by driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 1 +
 net/core/netpolicy.c      | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 00600f8..0eba512 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -76,6 +76,7 @@ struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
 	bool	has_mix_policy;
+	bool	queue_pair;
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index dc1edfc..735405c 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -495,6 +495,9 @@ int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
 	if (!policy_validate(instance))
 		return -EINVAL;
 
+	if (dev->netpolicy->queue_pair)
+		is_rx = true;
+
 	/* fast path */
 	rcu_read_lock();
 	version = (int *)rcu_dereference(netpolicy_sys_map_version);
-- 
2.5.5
