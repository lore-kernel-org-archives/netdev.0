From: Tejun Heo <tj@kernel.org>
Subject: [PATCH net-next] net, cgroup: cgroup_sk_updat_lock was missing
 initializer
Date: Mon, 14 Dec 2015 11:24:06 -0500
Message-ID: <20151214162406.GA4026@mtj.duckdns.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <f90d369a0e004fee8d3bfdfe95e0abc0@HKXPR3004MB0088.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dexuan Cui <decui@microsoft.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"daniel.wagner@bmw-carit.de" <daniel.wagner@bmw-carit.de>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"lizefan@huawei.com" <lizefan@huawei.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"ninasc@fb.com" <ninasc@fb.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f90d369a0e004fee8d3bfdfe95e0abc0@HKXPR3004MB0088.064d.mgd.msft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup") added global
spinlock cgroup_sk_update_lock but erroneously skipped initializer
leading to uninitialized spinlock warning.  Fix it by using
DEFINE_SPINLOCK().

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Dexuan Cui <decui@microsoft.com>
Fixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")
---
Hello, Dexuan.

Oops, sorry about that.  Somehow thought it was a different problem
which is already fixed.  This should do it.

Thanks.

 kernel/cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4f8f792..4466273f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5790,7 +5790,7 @@ EXPORT_SYMBOL_GPL(cgroup_get_from_path);
 
 #if defined(CONFIG_CGROUP_NET_PRIO) || defined(CONFIG_CGROUP_NET_CLASSID)
 
-spinlock_t cgroup_sk_update_lock;
+DEFINE_SPINLOCK(cgroup_sk_update_lock);
 static bool cgroup_sk_alloc_disabled __read_mostly;
 
 void cgroup_sk_alloc_disable(void)
