From: Patrick McHardy <kaber@trash.net>
Subject: vlan 02/07: Use is_vlan_dev()
Date: Mon,  7 Jul 2008 14:36:01 +0200 (MEST)
Message-ID: <20080707123600.23947.37696.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59273 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbYGGMgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:02 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Use is_vlan_dev()

Use simplified is_vlan_dev function.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5d835c9df8f14434867d206073316f771cfaac48
tree e30923fbd12ea4dbe12fb7a4b82d9e5261df935a
parent 12680f9e7c4d8c1d4dd89569e63f4f74d57243b0
author Joonwoo Park <joonwpark81@gmail.com> Mon, 07 Jul 2008 14:26:43 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:43 +0200

 net/8021q/vlan.c     |    3 +--
 net/8021q/vlan_dev.c |    2 +-
 net/8021q/vlanproc.c |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b529110..8141e2d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -570,8 +570,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 			goto out;
 
 		err = -EINVAL;
-		if (args.cmd != ADD_VLAN_CMD &&
-		    !(dev->priv_flags & IFF_802_1Q_VLAN))
+		if (args.cmd != ADD_VLAN_CMD && !is_vlan_dev(dev))
 			goto out;
 	}
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4a85259..88f318a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -694,7 +694,7 @@ static int vlan_dev_init(struct net_device *dev)
 		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
 	}
 
-	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(real_dev))
 		subclass = 1;
 
 	lockdep_set_class_and_subclass(&dev->_xmit_lock,
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 08b54b5..6073a88 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -290,7 +290,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
 
-	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN))
+	if (!is_vlan_dev(vlandev))
 		return 0;
 
 	seq_printf(seq,
