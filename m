From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/8021q/vlanproc.c: fix check-after-use
Date: Tue, 14 Aug 2007 23:22:44 +0200
Message-ID: <20070814212244.GB18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:38409 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752271AbXHNVWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 17:22:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted that we'd have already oops'ed if "vlandev"
was NULL.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- linux-2.6.23-rc1-mm2/net/8021q/vlanproc.c.old	2007-08-08 06:22:40.000000000 +0200
+++ linux-2.6.23-rc1-mm2/net/8021q/vlanproc.c	2007-08-08 06:23:13.000000000 +0200
@@ -314,17 +314,17 @@
 static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
 	const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
 	struct net_device_stats *stats;
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
 
-	if ((vlandev == NULL) || (!(vlandev->priv_flags & IFF_802_1Q_VLAN)))
+	if (!(vlandev->priv_flags & IFF_802_1Q_VLAN))
 		return 0;
 
 	seq_printf(seq, "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
 		       vlandev->name, dev_info->vlan_id,
 		       (int)(dev_info->flags & 1), vlandev->priv_flags);
 
 
 	stats = vlan_dev_get_stats(vlandev);

