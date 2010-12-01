From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] : __in_dev_get_rtnl() can use
 rtnl_dereference()
Date: Wed, 01 Dec 2010 12:37:42 +0100
Message-ID: <1291203462.2856.607.camel@edumazet-laptop>
References: <1291202063-6239-1-git-send-email-amwang@redhat.com>
	 <1291202476.2856.584.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291202476.2856.584.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 12:21 +0100, Eric Dumazet a =C3=
=A9crit :

> Same here. RTNL is held. Please use __in_dev_get_rtnl()

By the way we can use rtnl_dereference() in __in_dev_get_rtnl()

[PATCH net-next-2.6] : __in_dev_get_rtnl() can use rtnl_dereference()

If caller holds RTNL, we dont need a memory barrier
(smp_read_barrier_depends) included in rcu_dereference().

Just use rtnl_dereference() to properly document the assertions.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/inetdevice.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 2b86eaf..ae8fdc5 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -222,7 +222,7 @@ static inline struct in_device *in_dev_get(const st=
ruct net_device *dev)
=20
 static inline struct in_device *__in_dev_get_rtnl(const struct net_dev=
ice *dev)
 {
-	return rcu_dereference_check(dev->ip_ptr, lockdep_rtnl_is_held());
+	return rtnl_dereference(dev->ip_ptr);
 }
=20
 extern void in_dev_finish_destroy(struct in_device *idev);
