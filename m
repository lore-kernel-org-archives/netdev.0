From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 10/12]: wext: Remove compat handling from fs/compat_ioctl.c
Date: Tue, 17 Jun 2008 00:54:38 -0700 (PDT)
Message-ID: <20080617.005438.218071086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


wext: Remove compat handling from fs/compat_ioctl.c

No longer used.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 fs/compat_ioctl.c |  107 +----------------------------------------------------
 1 files changed, 1 insertions(+), 106 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 8ab850b..05ec7ee 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -58,7 +58,6 @@
 #include <linux/syscalls.h>
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
-#include <linux/wireless.h>
 #include <linux/atalk.h>
 #include <linux/loop.h>
 
@@ -1757,58 +1756,6 @@ static int do_i2c_smbus_ioctl(unsigned int fd, unsigned int cmd, unsigned long a
 	return sys_ioctl(fd, cmd, (unsigned long)tdata);
 }
 
-static int do_wireless_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	struct iwreq __user *iwr;
-	struct iwreq __user *iwr_u;
-	struct iw_point __user *iwp;
-	struct compat_iw_point __user *iwp_u;
-	compat_caddr_t pointer_u;
-	void __user *pointer;
-	__u16 length, flags;
-	int ret;
-
-	iwr_u = compat_ptr(arg);
-	iwp_u = (struct compat_iw_point __user *) &iwr_u->u.data;
-	iwr = compat_alloc_user_space(sizeof(*iwr));
-	if (iwr == NULL)
-		return -ENOMEM;
-
-	iwp = &iwr->u.data;
-
-	if (!access_ok(VERIFY_WRITE, iwr, sizeof(*iwr)))
-		return -EFAULT;
-
-	if (__copy_in_user(&iwr->ifr_ifrn.ifrn_name[0],
-			   &iwr_u->ifr_ifrn.ifrn_name[0],
-			   sizeof(iwr->ifr_ifrn.ifrn_name)))
-		return -EFAULT;
-
-	if (__get_user(pointer_u, &iwp_u->pointer) ||
-	    __get_user(length, &iwp_u->length) ||
-	    __get_user(flags, &iwp_u->flags))
-		return -EFAULT;
-
-	if (__put_user(compat_ptr(pointer_u), &iwp->pointer) ||
-	    __put_user(length, &iwp->length) ||
-	    __put_user(flags, &iwp->flags))
-		return -EFAULT;
-
-	ret = sys_ioctl(fd, cmd, (unsigned long) iwr);
-
-	if (__get_user(pointer, &iwp->pointer) ||
-	    __get_user(length, &iwp->length) ||
-	    __get_user(flags, &iwp->flags))
-		return -EFAULT;
-
-	if (__put_user(ptr_to_compat(pointer), &iwp_u->pointer) ||
-	    __put_user(length, &iwp_u->length) ||
-	    __put_user(flags, &iwp_u->flags))
-		return -EFAULT;
-
-	return ret;
-}
-
 /* Since old style bridge ioctl's endup using SIOCDEVPRIVATE
  * for some operations; this forces use of the newer bridge-utils that
  * use compatiable ioctls
@@ -2489,36 +2436,6 @@ COMPATIBLE_IOCTL(I2C_TENBIT)
 COMPATIBLE_IOCTL(I2C_PEC)
 COMPATIBLE_IOCTL(I2C_RETRIES)
 COMPATIBLE_IOCTL(I2C_TIMEOUT)
-/* wireless */
-COMPATIBLE_IOCTL(SIOCSIWCOMMIT)
-COMPATIBLE_IOCTL(SIOCGIWNAME)
-COMPATIBLE_IOCTL(SIOCSIWNWID)
-COMPATIBLE_IOCTL(SIOCGIWNWID)
-COMPATIBLE_IOCTL(SIOCSIWFREQ)
-COMPATIBLE_IOCTL(SIOCGIWFREQ)
-COMPATIBLE_IOCTL(SIOCSIWMODE)
-COMPATIBLE_IOCTL(SIOCGIWMODE)
-COMPATIBLE_IOCTL(SIOCSIWSENS)
-COMPATIBLE_IOCTL(SIOCGIWSENS)
-COMPATIBLE_IOCTL(SIOCSIWRANGE)
-COMPATIBLE_IOCTL(SIOCSIWPRIV)
-COMPATIBLE_IOCTL(SIOCSIWSTATS)
-COMPATIBLE_IOCTL(SIOCSIWAP)
-COMPATIBLE_IOCTL(SIOCGIWAP)
-COMPATIBLE_IOCTL(SIOCSIWRATE)
-COMPATIBLE_IOCTL(SIOCGIWRATE)
-COMPATIBLE_IOCTL(SIOCSIWRTS)
-COMPATIBLE_IOCTL(SIOCGIWRTS)
-COMPATIBLE_IOCTL(SIOCSIWFRAG)
-COMPATIBLE_IOCTL(SIOCGIWFRAG)
-COMPATIBLE_IOCTL(SIOCSIWTXPOW)
-COMPATIBLE_IOCTL(SIOCGIWTXPOW)
-COMPATIBLE_IOCTL(SIOCSIWRETRY)
-COMPATIBLE_IOCTL(SIOCGIWRETRY)
-COMPATIBLE_IOCTL(SIOCSIWPOWER)
-COMPATIBLE_IOCTL(SIOCGIWPOWER)
-COMPATIBLE_IOCTL(SIOCSIWAUTH)
-COMPATIBLE_IOCTL(SIOCGIWAUTH)
 /* hiddev */
 COMPATIBLE_IOCTL(HIDIOCGVERSION)
 COMPATIBLE_IOCTL(HIDIOCAPPLICATION)
@@ -2749,29 +2666,7 @@ COMPATIBLE_IOCTL(USBDEVFS_IOCTL32)
 HANDLE_IOCTL(I2C_FUNCS, w_long)
 HANDLE_IOCTL(I2C_RDWR, do_i2c_rdwr_ioctl)
 HANDLE_IOCTL(I2C_SMBUS, do_i2c_smbus_ioctl)
-/* wireless */
-HANDLE_IOCTL(SIOCGIWRANGE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWPRIV, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWSTATS, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWSPY, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWSPY, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWTHRSPY, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWTHRSPY, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWMLME, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWAPLIST, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWSCAN, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWSCAN, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWESSID, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWESSID, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWGENIE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWGENIE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWENCODEEXT, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCGIWENCODEEXT, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIWPMKSA, do_wireless_ioctl)
+/* bridge */
 HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
 HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
 /* Not implemented in the native kernel */
-- 
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
