From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] tuntap: correct the return value in tun_set_iff()
Date: Tue, 23 Apr 2013 14:40:39 +0800
Message-ID: <1366699239-6866-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, Jerry Chu <hkchu@google.com>,
	Wei Yongjun <weiyj.lk@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit (3be8fbab tuntap: fix error return code in tun_set_iff()) breaks the
creation of multiqueue tuntap since it forbids to create more than one queues
for a multiqueue tuntap device. We need return 0 instead -EBUSY here since we
don't want to re-initialize the device when one or more queues has been already
attached. Add a comment and correct the return value to zero.

Reported-by: Jerry Chu <hkchu@google.com>
Cc: Jerry Chu <hkchu@google.com>
Cc: Wei Yongjun <weiyj.lk@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 729ed53..3a8977e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1594,7 +1594,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		if (tun->flags & TUN_TAP_MQ &&
 		    (tun->numqueues + tun->numdisabled > 1))
-			return -EBUSY;
+			/* One or more queue has already been attached, no need
+			 * to initialize the device again.
+			 */
+			return 0;
 	}
 	else {
 		char *name;
-- 
1.7.1
