From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] netns: remove BUG_ONs from net_generic()
Date: Fri, 17 Apr 2015 19:06:30 +0200
Message-ID: <1429290390-5600-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This inline has ~500 callsites.

On 04/14/2015 08:37 PM, David Miller wrote:
> That BUG_ON() was added 7 years ago, and I don't remember it ever
> triggering or helping us diagnose something, so just remove it and
> keep the function inlined.

On x86 allyesconfig build:

    text     data      bss       dec     hex filename
82447071 22255384 20627456 125329911 77861f7 vmlinux4
82441375 22255384 20627456 125324215 7784bb7 vmlinux5prime

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
CC: David S. Miller <davem@davemloft.net>
CC: Jan Engelhardt <jengelh@medozas.de>
CC: Jiri Pirko <jpirko@redhat.com>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
---
 include/net/netns/generic.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
index 0931618..70e1585 100644
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -38,11 +38,9 @@ static inline void *net_generic(const struct net *net, int id)
 
 	rcu_read_lock();
 	ng = rcu_dereference(net->gen);
-	BUG_ON(id == 0 || id > ng->len);
 	ptr = ng->ptr[id - 1];
 	rcu_read_unlock();
 
-	BUG_ON(!ptr);
 	return ptr;
 }
 #endif
-- 
1.8.1.4
