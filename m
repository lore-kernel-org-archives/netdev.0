From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] PKT_SCHED: u32 ematch
Date: Mon, 24 Jan 2005 01:24:13 +0100
Message-ID: <41F4402D.6040200@trash.net>
References: <20050123230012.GB23931@postel.suug.ch> <20050123230354.GF23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050123230354.GF23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>diff -Nru linux-2.6.11-rc1-bk9.orig/net/sched/em_u32.c linux-2.6.11-rc1-bk9/net/sched/em_u32.c
>--- linux-2.6.11-rc1-bk9.orig/net/sched/em_u32.c	1970-01-01 01:00:00.000000000 +0100
>+++ linux-2.6.11-rc1-bk9/net/sched/em_u32.c	2005-01-22 12:37:28.000000000 +0100
>@@ -0,0 +1,58 @@
>+/*
>+ * net/sched/em_u32.c	U32 Ematch
>+ *
>+ *		This program is free software; you can redistribute it and/or
>+ *		modify it under the terms of the GNU General Public License
>+ *		as published by the Free Software Foundation; either version
>+ *		2 of the License, or (at your option) any later version.
>+ *
>+ * Authors:	Thomas Graf <tgraf@suug.ch>
>+ *		Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
>+ *
>+ * Based on net/sched/cls_u32.c
>+ */
>+
>+#include <linux/config.h>
>+#include <linux/module.h>
>+#include <linux/types.h>
>+#include <linux/kernel.h>
>+#include <linux/skbuff.h>
>+#include <net/pkt_cls.h>
>+
>+static int em_u32_match(struct sk_buff *skb, struct tcf_ematch *em,
>+			struct tcf_pkt_info *info)
>+{
>+	struct tc_u32_key *key = (struct tc_u32_key *) em->data;
>+	unsigned char *ptr = skb->nh.raw;
>+	
>+	if (info) {
>+		if (info->ptr)
>+			ptr = info->ptr;
>+		ptr += (info->nexthdr & key->offmask);
>+	}
>+	
>+	return !((*(u32*) (ptr + key->off) ^ key->val) & key->mask);
>  
>
This needs to make sure it stays inside the skb. I know cls_u32's checks
are pretty weak, but having nothing doesn't seem right.

>+}
>+
>+static struct tcf_ematch_ops em_u32_ops = {
>+	.kind	  = TCF_EM_U32,
>+	.datalen  = sizeof(struct tc_u32_key),
>+	.match	  = em_u32_match,
>+	.owner	  = THIS_MODULE,
>+	.link	  = LIST_HEAD_INIT(em_u32_ops.link)
>+};
>+
>+static int __init init_em_u32(void)
>+{
>+	return tcf_em_register(&em_u32_ops);
>+}
>+
>+static void __exit exit_em_u32(void) 
>+{
>+	tcf_em_unregister(&em_u32_ops);
>+}
>+
>+MODULE_LICENSE("GPL");
>+
>+module_init(init_em_u32);
>+module_exit(exit_em_u32);
>
>  
>
