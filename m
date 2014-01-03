From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: [RFC PATCH net-next 1/4] net: introduce backup_classid to struct
 skbuff
Date: Fri, 3 Jan 2014 11:11:04 +0800
Message-ID: <52C62A48.1050604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <jasowang@redhat.com>, <horms@verge.net.au>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	<netdev@vger.kernel.org>, <cgroups@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <kaber@trash.net>,
	<xemul@openvz.org>, <ebiederm@xmission.com>,
	LKML <linux-kernel@vger.kernel.org>, <jhs@mojatatu.com>,
	Li Zefan <lizefan@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


introduce backup_classid to struct skbuff,
we can use it to backup sk_classid when net_ns switch.

Signed-off-by: Libo Chen <clbchenlibo.chen@huawei.com>
---
 include/linux/skbuff.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c5cd016..b76e871 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -492,6 +492,9 @@ struct sk_buff {
 #ifdef CONFIG_NET_CLS_ACT
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
+#ifdef CONFIG_NET_CLS_CGROUP
+	__u32			backup_classid;
+#endif
 #endif

 	__u16			queue_mapping;
-- 
1.8.2.2
