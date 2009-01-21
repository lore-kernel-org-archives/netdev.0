From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH NET-NEXT 07/12] net: pass new SIOCSHWTSTAMP through to device drivers
Date: Wed, 21 Jan 2009 11:10:07 +0100
Message-ID: <1232532612-10382-7-git-send-email-patrick.ohly@intel.com>
References: <1232532457.7829.19.camel@ecld0pohly>
 <1232532612-10382-1-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-2-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-3-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-4-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-5-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-6-git-send-email-patrick.ohly@intel.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1232532612-10382-6-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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
index 93b2ac9..370c9f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3864,6 +3864,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			    cmd == SIOCSMIIREG ||
 			    cmd == SIOCBRADDIF ||
 			    cmd == SIOCBRDELIF ||
+			    cmd == SIOCSHWTSTAMP ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
 				if (ops->ndo_do_ioctl) {
@@ -4018,6 +4019,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		case SIOCBONDCHANGEACTIVE:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
+		case SIOCSHWTSTAMP:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			/* fall through */
-- 
1.5.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
