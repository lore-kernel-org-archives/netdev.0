From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH 1/1] isdn: Make CONFIG_ISDN depend on CONFIG_NETDEVICES
Date: Wed,  7 Nov 2012 10:55:03 +0100
Message-ID: <1352282103-13665-1-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Lee Jones <lee.jones@linaro.org>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It doesn't make much sense to enable ISDN services if you don't
intend to connect to a network. Therefore insisting that ISDN
depends on NETDEVICES seems logical. We can then remove any
guards mentioning NETDEVICES inside all subordinate drivers.

This also has the nice side-effect of fixing the warning below
when ISDN_I4L && !CONFIG_NETDEVICES at compile time.

This patch fixes:
drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=80=99=
:
drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=80=98=
s=E2=80=99 [-Wunused-variable]

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
Signed-off-by: Lee Jones <lee.jones@linaro.org>
---
 drivers/isdn/Kconfig           |    2 +-
 drivers/isdn/i4l/Kconfig       |    2 +-
 drivers/isdn/i4l/isdn_common.c |    4 ----
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/Kconfig b/drivers/isdn/Kconfig
index a233ed5..86cd75a 100644
--- a/drivers/isdn/Kconfig
+++ b/drivers/isdn/Kconfig
@@ -4,7 +4,7 @@
=20
 menuconfig ISDN
 	bool "ISDN support"
-	depends on NET
+	depends on NET && NETDEVICES
 	depends on !S390 && !UML
 	---help---
 	  ISDN ("Integrated Services Digital Network", called RNIS in France)
diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index 2302fbe..9c6650e 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -6,7 +6,7 @@ if ISDN_I4L
=20
 config ISDN_PPP
 	bool "Support synchronous PPP"
-	depends on INET && NETDEVICES
+	depends on INET
 	select SLHC
 	help
 	  Over digital connections such as ISDN, there is no need to
diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_com=
mon.c
index 8c610fa..e2a945e 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -1312,7 +1312,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 			} else
 				return -EINVAL;
 			break;
-#ifdef CONFIG_NETDEVICES
 		case IIOCNETGPN:
 			/* Get peer phone number of a connected
 			 * isdn network interface */
@@ -1322,7 +1321,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 				return isdn_net_getpeer(&phone, argp);
 			} else
 				return -EINVAL;
-#endif
 		default:
 			return -EINVAL;
 		}
@@ -1352,7 +1350,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 		case IIOCNETLCR:
 			printk(KERN_INFO "INFO: ISDN_ABC_LCR_SUPPORT not enabled\n");
 			return -ENODEV;
-#ifdef CONFIG_NETDEVICES
 		case IIOCNETAIF:
 			/* Add a network-interface */
 			if (arg) {
@@ -1491,7 +1488,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 				return -EFAULT;
 			return isdn_net_force_hangup(name);
 			break;
-#endif                          /* CONFIG_NETDEVICES */
 		case IIOCSETVER:
 			dev->net_verbose =3D arg;
 			printk(KERN_INFO "isdn: Verbose-Level is %d\n", dev->net_verbose);
--=20
1.7.9.5
