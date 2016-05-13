From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH 2/3] netfilter: ipset: use setup_timer() and mod_timer().
Date: Sat, 14 May 2016 02:28:53 +0530
Message-ID: <1463173145-16167-2-git-send-email-falakreyaz@gmail.com>
References: <1463173145-16167-1-git-send-email-falakreyaz@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Joshua Hunt <johunt@akamai.com>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Vishwanath Pai <vpai@akamai.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463173145-16167-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use setup_timer() and instead of init_timer(), being the preferred way
of setting up a timer.

Also, quoting the mod_timer() function comment:
-> mod_timer() is a more efficient way to update the expire field of an
   active timer (if the timer is inactive it will be activated).

Use setup_timer() and mod_timer() to setup and arm a timer, making the
code compact and easier to read.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index d32fd6b..5a06ff2 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -444,11 +444,8 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct htype *h = set->data;
 
-	init_timer(&h->gc);
-	h->gc.data = (unsigned long)set;
-	h->gc.function = gc;
-	h->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
-	add_timer(&h->gc);
+	setup_timer(&h->gc, gc, (unsigned long)set);
+	mod_timer(&h->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
 	pr_debug("gc initialized, run in every %u\n",
 		 IPSET_GC_PERIOD(set->timeout));
 }
-- 
1.9.1
