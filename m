From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 11/15] [IPV6]: Use proc_create() to setup ->proc_fops first
Date: Thu, 28 Feb 2008 18:57:49 +0800
Message-ID: <47C693AD.5050705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57886 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbYB1LAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:00:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() to make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv6/proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 35e502a..199ef37 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -217,12 +217,12 @@ int snmp6_register_dev(struct inet6_dev *idev)
 	if (!proc_net_devsnmp6)
 		return -ENOENT;
 
-	p = create_proc_entry(idev->dev->name, S_IRUGO, proc_net_devsnmp6);
+	p = proc_create(idev->dev->name, S_IRUGO,
+			proc_net_devsnmp6, &snmp6_seq_fops);
 	if (!p)
 		return -ENOMEM;
 
 	p->data = idev;
-	p->proc_fops = &snmp6_seq_fops;
 
 	idev->stats.proc_dir_entry = p;
 	return 0;
-- 
WCN


