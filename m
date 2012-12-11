From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next rfc 1/2] tuntap: forbid calling TUNSETQUEUE for a persistent device with no queues
Date: Tue, 11 Dec 2012 19:03:46 +0800
Message-ID: <1355223827-57290-2-git-send-email-jasowang@redhat.com>
References: <1355223827-57290-1-git-send-email-jasowang@redhat.com>
Cc: mprivozn@redhat.com, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, pmoore@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355223827-57290-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When re-establish to a persistent deivce wihout queues attached, TUNSETIFF
should be called instead of TUNSETQUEUE to do the proper permission checking.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 14a0454..d593f56 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1771,6 +1771,9 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 			ret = -EINVAL;
 		else if (tun_not_capable(tun))
 			ret = -EPERM;
+		/* TUNSETIFF is needed to do permission checking */
+		else if (tun->numqueues == 0)
+			ret = -EPERM;
 		else
 			ret = tun_attach(tun, file);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE)
-- 
1.7.1
