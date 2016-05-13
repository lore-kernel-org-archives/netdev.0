From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH 3/3] netfilter: ipset: use setup_timer() and mod_timer().
Date: Sat, 14 May 2016 02:28:54 +0530
Message-ID: <1463173145-16167-3-git-send-email-falakreyaz@gmail.com>
References: <1463173145-16167-1-git-send-email-falakreyaz@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Joshua Hunt <johunt@akamai.com>,
	Nikolay Borisov <kernel@kyup.com>,
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
 net/netfilter/ipset/ip_set_list_set.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index a2a89e4..530da56 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -570,11 +570,8 @@ list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct list_set *map = set->data;
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long)set;
-	map->gc.function = gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
-	add_timer(&map->gc);
+	setup_timer(&map->gc, gc, (unsigned long)set);
+	mod_timer(&map->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
 }
 
 /* Create list:set type of sets */
-- 
1.9.1
