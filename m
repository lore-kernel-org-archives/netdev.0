From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 2/4] livepatch: use list_is_first()
Date: Thu, 10 Dec 2015 22:17:16 +0800
Message-ID: <394e9e5ece944969fe1ff4f37c9a73bf5543265e.1449755818.git.geliangtang@163.com>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Axboe <axboe@kernel.dk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
In-Reply-To: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For better readability, use list_is_first() instead of open-coded.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 kernel/livepatch/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/livepatch/core.c b/kernel/livepatch/core.c
index bc2c85c..be64106 100644
--- a/kernel/livepatch/core.c
+++ b/kernel/livepatch/core.c
@@ -479,7 +479,7 @@ static int __klp_enable_patch(struct klp_patch *patch)
 		return -EINVAL;
 
 	/* enforce stacking: only the first disabled patch can be enabled */
-	if (patch->list.prev != &klp_patches &&
+	if (!list_is_first(&patch->list, &klp_patches) &&
 	    list_prev_entry(patch, list)->state == KLP_DISABLED)
 		return -EBUSY;
 
-- 
2.5.0
