From: Timo =?iso-8859-1?Q?Ter=E4s?= <ext-timo.teras@nokia.com>
Subject: [PATCH] Add ability to register class interfaces for network class
Date: Tue, 26 Oct 2004 21:35:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026183526.GA23535@two.research.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add functions to register class interfaces for network class.
Similar to the ones found in scsi subsystem.

Originally posted on linux-net and related discussion can be found
from http://marc.theaimsgroup.com/?l=3Dlinux-net&m=3D109758592121767&w=3D=
2.

Signed-off-by: Timo Ter=E4s <ext-timo.teras@nokia.com>

--- linux-2.6.9-rc4.orig/net/core/net-sysfs.c	2004-10-12 13:23:35.1064963=
12 +0300
+++ linux-2.6.9-rc4/net/core/net-sysfs.c	2004-10-12 13:24:29.177276304 +0=
300
@@ -448,3 +448,11 @@
  {
  	return class_register(&net_class);
  }
+
+int netdev_register_interface(struct class_interface *intf)
+{
+	intf->class =3D &net_class;
+	return class_interface_register(intf);
+}
+
+EXPORT_SYMBOL_GPL(netdev_register_interface);
--- linux-2.6.9-rc4.orig/include/linux/netdevice.h	2004-10-12 13:23:31.18=
6092304 +0300
+++ linux-2.6.9-rc4/include/linux/netdevice.h	2004-10-12 13:24:29.1792760=
00 +0300
@@ -951,6 +951,12 @@
  extern char *net_sysctl_strdup(const char *s);
  #endif

+#ifdef CONFIG_SYSFS
+extern int netdev_register_interface(struct class_interface *intf);
+#define netdev_unregister_interface(intf) \
+	class_interface_unregister(intf)
+#endif
+
  #endif /* __KERNEL__ */

  #endif	/* _LINUX_DEV_H */
