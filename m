From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 07/10] net: pass new SIOCSHWTSTAMP through to device drivers
Date: Thu, 12 Feb 2009 16:00:09 +0100
Message-ID: <1234450812-6246-7-git-send-email-patrick.ohly@intel.com>
References: <1234450670.5914.9.camel@ecld0pohly>
 <1234450812-6246-1-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-2-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-3-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-4-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-5-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-6-git-send-email-patrick.ohly@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	John Ronciak <john.ronciak@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27453 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758946AbZBLPAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:00:33 -0500
In-Reply-To: <1234450812-6246-6-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 fs/compat_ioctl.c |    6 ++++++
 net/core/dev.c    |    2 ++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index c03c10d..ab7585a 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -522,6 +522,11 @@ static int dev_ifsioc(unsigned int fd, unsigned int cmd, unsigned long arg)
 		if (err)
 			return -EFAULT;
 		break;
+	case SIOCSHWTSTAMP:
+		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
+			return -EFAULT;
+		ifr.ifr_data = compat_ptr(uifr32->ifr_ifru.ifru_data);
+		break;
 	default:
 		if (copy_from_user(&ifr, uifr32, sizeof(*uifr32)))
 			return -EFAULT;
@@ -2563,6 +2568,7 @@ HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
+HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
 
 /* ioctls used by appletalk ddp.c */
 HANDLE_IOCTL(SIOCATALKDIFADDR, dev_ifsioc)
diff --git a/net/core/dev.c b/net/core/dev.c
index d20c28e..d393fc9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4019,6 +4019,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			    cmd == SIOCSMIIREG ||
 			    cmd == SIOCBRADDIF ||
 			    cmd == SIOCBRDELIF ||
+			    cmd == SIOCSHWTSTAMP ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
 				if (ops->ndo_do_ioctl) {
@@ -4173,6 +4174,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		case SIOCBONDCHANGEACTIVE:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
+		case SIOCSHWTSTAMP:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			/* fall through */
-- 
1.6.1.2

