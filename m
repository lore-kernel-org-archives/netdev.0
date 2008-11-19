From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 06/11] net: pass new SIOCSHWTSTAMP through to device drivers
Date: Wed, 19 Nov 2008 13:08:43 +0100
Message-ID: <1227096528-24150-7-git-send-email-patrick.ohly@intel.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-6-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick Ohly <patrick.ohly@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34262 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695AbYKSMJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:09:04 -0500
In-Reply-To: <1227096528-24150-6-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 fs/compat_ioctl.c |    1 +
 net/core/dev.c    |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 5235c67..a5001a6 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2555,6 +2555,7 @@ HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
+HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
 
 /* ioctls used by appletalk ddp.c */
 HANDLE_IOCTL(SIOCATALKDIFADDR, dev_ifsioc)
diff --git a/net/core/dev.c b/net/core/dev.c
index b4b8eb8..4f61f5e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3650,6 +3650,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			    cmd == SIOCSMIIREG ||
 			    cmd == SIOCBRADDIF ||
 			    cmd == SIOCBRDELIF ||
+			    cmd == SIOCSHWTSTAMP ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
 				if (dev->do_ioctl) {
@@ -3805,6 +3806,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		case SIOCBONDCHANGEACTIVE:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
+		case SIOCSHWTSTAMP:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			/* fall through */
-- 
1.6.0.4

