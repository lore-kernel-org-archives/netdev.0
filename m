From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 02/10] bpf: move bpf_jit_enable declaration
Date: Fri, 13 May 2016 19:08:27 +0200
Message-ID: <988f1e6be0d5df9b5729033b77dc25a3344a68a7.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41858 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456AbcEMRJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:05 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the bpf_jit_enable declaration to the filter.h file where
most other core code is declared, also since we're going to add
a second knob there.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/filter.h    | 2 ++
 include/linux/netdevice.h | 1 -
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index ec1411c..4ff0e64 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -496,6 +496,8 @@ void bpf_int_jit_compile(struct bpf_prog *fp);
 bool bpf_helper_changes_skb_data(void *func);
 
 #ifdef CONFIG_BPF_JIT
+extern int bpf_jit_enable;
+
 typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
 
 struct bpf_binary_header *
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 63580e6..c23fd73 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3757,7 +3757,6 @@ void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
-extern int		bpf_jit_enable;
 
 bool netdev_has_upper_dev(struct net_device *dev, struct net_device *upper_dev);
 struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *dev,
-- 
1.9.3
