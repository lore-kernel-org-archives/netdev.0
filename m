From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 10:06:44 +0100
Message-ID: <1263114404-9340-1-git-send-email-jslaby@suse.cz>
Cc: linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753069Ab0AJJGz@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found a potential null dereference in snmp6_unregister_dev.
There is a check for idev being NULL, but it is dereferenced
earlier. Move the dereference after the check.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv6/proc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index c9605c3..53f4ef5 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -256,11 +256,12 @@ int snmp6_register_dev(struct inet6_dev *idev)
 
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
-	struct net *net = dev_net(idev->dev);
-	if (!net->mib.proc_net_devsnmp6)
-		return -ENOENT;
+	struct net *net;
 	if (!idev || !idev->stats.proc_dir_entry)
 		return -EINVAL;
+	net = dev_net(idev->dev);
+	if (!net->mib.proc_net_devsnmp6)
+		return -ENOENT;
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  net->mib.proc_net_devsnmp6);
 	idev->stats.proc_dir_entry = NULL;
-- 
1.6.5.7
