From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH]  allow CONFIG_NET=n on ppc64
Date: Sat, 2 Oct 2004 17:30:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002153053.GA2643@suse.de>
References: <20040929200158.GA16366@suse.de> <20040929201524.GA14615@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20040929201524.GA14615@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Wed, Sep 29, Andi Kleen wrote:

> On Wed, Sep 29, 2004 at 10:01:58PM +0200, Olaf Hering wrote:
> >=20
> > The attached minimal config does not compile on ppc64.
> > I was able to boot the resulting binary with this patch.

> Right fix is to declare compat_sys_socketcall as as cond_syscall()=20
> in sys.c

ok.

Signed-off-by: Olaf Hering <olh@suse.de>

diff -purNX /suse/olh/kernel/kernel_exclude.txt linux-2.6.9-rc3-bk2/inclu=
de/net/sock.h linux-2.6.9-rc3-bk2.nonet/include/net/sock.h
--- linux-2.6.9-rc3-bk2/include/net/sock.h	2004-09-30 05:05:21.000000000 =
+0200
+++ linux-2.6.9-rc3-bk2.nonet/include/net/sock.h	2004-10-02 17:24:23.6661=
52810 +0200
@@ -1336,6 +1336,13 @@ static inline void sock_valbool_flag(str
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
=20
+#ifdef CONFIG_NET
 int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd, unsigned lon=
g arg);
+#else
+static inline int siocdevprivate_ioctl(unsigned int fd, unsigned int cmd=
, unsigned long arg)
+{
+	return -ENODEV;
+}
+#endif
=20
 #endif	/* _SOCK_H */
diff -purNX /suse/olh/kernel/kernel_exclude.txt linux-2.6.9-rc3-bk2/kerne=
l/sys.c linux-2.6.9-rc3-bk2.nonet/kernel/sys.c
--- linux-2.6.9-rc3-bk2/kernel/sys.c	2004-09-30 05:03:55.000000000 +0200
+++ linux-2.6.9-rc3-bk2.nonet/kernel/sys.c	2004-10-02 17:05:49.589116448 =
+0200
@@ -282,6 +282,7 @@ cond_syscall(compat_set_mempolicy)
 cond_syscall(sys_pciconfig_read)
 cond_syscall(sys_pciconfig_write)
 cond_syscall(sys_pciconfig_iobase)
+cond_syscall(compat_sys_socketcall)
=20
 static int set_one_prio(struct task_struct *p, int niceval, int error)
 {

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
