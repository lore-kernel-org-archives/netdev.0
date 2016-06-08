From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: sched: fix missing doc annotations
Date: Wed, 08 Jun 2016 07:22:49 -0700
Message-ID: <1465395769.7945.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36778 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423238AbcFHOWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 10:22:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id 62so724458pfd.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 07:22:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

"make htmldocs" complains otherwise:

.//net/core/gen_stats.c:168: warning: No description found for parameter 'running'
.//include/linux/netdevice.h:1867: warning: No description found for parameter 'qdisc_running_key'

Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
Fixes: edb09eb17ed8 ("net: sched: do not acquire qdisc spinlock in qdisc/class stats dump")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 include/linux/netdevice.h |    3 ++-
 net/core/gen_stats.c      |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59d7e06d88d5d9f0358eb2916d2e1aebc53d64e3..541562333ba5dd9184205364d378d0a72c6026f9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1594,7 +1594,8 @@ enum netdev_priv_flags {
  *	@phydev:	Physical device may attach itself
  *			for hardware timestamping
  *
- *	@qdisc_tx_busylock:	XXX: need comments on this one
+ *	@qdisc_tx_busylock: lockdep class annotating Qdisc->busylock spinlock
+ *	@qdisc_running_key: lockdep class annotating Qdisc->running seqcount
  *
  *	@proto_down:	protocol port state information can be sent to the
  *			switch driver and used to set the phys state of the
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index d9c210caff32f3c3044723f094fc0349dc516381..32207e6a942cd7093a0819310afb4500f9590ceb 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -150,6 +150,7 @@ EXPORT_SYMBOL(__gnet_stats_copy_basic);
 
 /**
  * gnet_stats_copy_basic - copy basic statistics into statistic TLV
+ * @running: seqcount_t pointer
  * @d: dumping handle
  * @cpu: copy statistic per cpu
  * @b: basic statistics
