From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] irlan: fix header build warning
Date: Wed, 6 Dec 2006 17:08:18 -0800
Message-ID: <20061206170818.86c355cb.randy.dunlap@oracle.com>
References: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
	<20061206.165717.21938171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56477 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937894AbWLGBHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 20:07:37 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061206.165717.21938171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Dec 2006 16:57:17 -0800 (PST) David Miller wrote:

> How about we protect these function externs with CONFIG_PROC_FS ifdefs
> instead?

Sure.

---
From: Randy Dunlap <randy.dunlap@oracle.com>

Fix compile warning when CONFIG_PROC_FS=n:

include/net/irda/irlan_filter.h:31: warning: 'struct seq_file' declared inside parameter list
include/net/irda/irlan_filter.h:31: warning: its scope is only this definition or declaration, which is probably not what you want

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/irda/irlan_filter.h |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.19-git7.orig/include/net/irda/irlan_filter.h
+++ linux-2.6.19-git7/include/net/irda/irlan_filter.h
@@ -28,6 +28,8 @@
 void irlan_check_command_param(struct irlan_cb *self, char *param, 
 			       char *value);
 void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb);
+#ifdef CONFIG_PROC_FS
 void irlan_print_filter(struct seq_file *seq, int filter_type);
+#endif
 
 #endif /* IRLAN_FILTER_H */
