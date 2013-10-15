From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 01/18] netfilter: cleanup: delete Macro PRINTR
Date: Tue, 15 Oct 2013 19:44:57 +0800
Message-ID: <1381837514-50660-2-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Macro PRINTR is only used once in nfnetlink_log.c, so it can be
replaced by helper function net_err_ratelimited().

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 net/netfilter/nfnetlink_log.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index d92cc31..8713111 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -47,9 +47,6 @@
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
 #define NFULNL_COPY_RANGE_MAX	0xFFFF	/* max packet size is limited by 16-bit struct nfattr nfa_len field */
 
-#define PRINTR(x, args...)	do { if (net_ratelimit()) \
-				     printk(x, ## args); } while (0);
-
 struct nfulnl_instance {
 	struct hlist_node hlist;	/* global list of instances */
 	spinlock_t lock;
@@ -587,7 +584,7 @@ __build_packet_message(struct nfnl_log_net *log,
 	return 0;
 
 nla_put_failure:
-	PRINTR(KERN_ERR "nfnetlink_log: error creating log nlmsg\n");
+	net_err_ratelimited("nfnetlink_log: error creating log nlmsg\n");
 	return -1;
 }
 
-- 
1.8.2.1
