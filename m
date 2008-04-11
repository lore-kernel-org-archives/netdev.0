From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 3/5] [VLAN]: Use is_vlan_dev()
Date: Fri, 11 Apr 2008 22:58:25 +0900
Message-ID: <20080411135825.GC8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:5278 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758868AbYDKN6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:58:38 -0400
Received: by wf-out-1314.google.com with SMTP id 28so499384wff.4
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:58:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use simplified is_vlan_dev function.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/8021q/vlan.c     |    3 +--
 net/8021q/vlan_dev.c |    2 +-
 net/8021q/vlanproc.c |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b33410a..a213bd1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -527,8 +527,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 			goto out;
 
 		err = -EINVAL;
-		if (args.cmd != ADD_VLAN_CMD &&
-		    !(dev->priv_flags & IFF_802_1Q_VLAN))
+		if (args.cmd != ADD_VLAN_CMD && !is_vlan_dev(dev))
 			goto out;
 	}
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 480ea90..df9786f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -684,7 +684,7 @@ static int vlan_dev_init(struct net_device *dev)
 		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
 	}
 
-	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(real_dev))
 		subclass = 1;
 
 	lockdep_set_class_and_subclass(&dev->_xmit_lock,
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 9671aa5..5727f57 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -289,7 +289,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
 
-	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN))
+	if (!is_vlan_dev(vlandev))
 		return 0;
 
 	seq_printf(seq,
-- 
1.5.4.3


