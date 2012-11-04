From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH v2 8/9] isdn: Remove unused variable causing a compile build
 warning
Date: Sun, 4 Nov 2012 11:28:40 +0100
Message-ID: <20121104102840.GA27124@gmail.com>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
 <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
 <1351982441.1434.5.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351982441.1434.5.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for reviewing Paul. Here's the result:

Author: Lee Jones <lee.jones@linaro.org>
Date:   Sat Nov 3 22:06:02 2012 +0100

    isdn: Encapsulate variable 's' in same CONFIG_NETDEVICES guards as =
code using it
   =20
    In the current case, variable 's' of type 'char *' is defined but t=
hen
    not used if !CONFIG_NETDEVICES, casing the compile-time warning bel=
ow.
    In this change we surround the declaration using the same guards as
    the pre-processed code which makes use of it.
   =20
    This patch fixes:
    drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=80=
=99:
    drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=
=80=98s=E2=80=99 [-Wunused-variable]
   =20
    Cc: Karsten Keil <isdn@linux-pingi.de>
    Cc: netdev@vger.kernel.org
    Signed-off-by: Lee Jones <lee.jones@linaro.org>

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_com=
mon.c
index 8c610fa..2875f31 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -1275,7 +1275,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 	int ret;
 	int i;
 	char __user *p;
-	char *s;
 	union iocpar {
 		char name[10];
 		char bname[22];
@@ -1284,6 +1283,9 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 		isdn_net_ioctl_cfg cfg;
 	} iocpar;
 	void __user *argp =3D (void __user *)arg;
+#ifdef CONFIG_NETDEVICES
+	char *s;
+#endif
=20
 #define name  iocpar.name
 #define bname iocpar.bname
