From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH] uapi glibc compat: fix cases where glibc net/if.h is included before linux/if.h
Date: Sun,  7 Feb 2016 16:03:21 +0200
Message-ID: <1454853801-18064-1-git-send-email-mikko.rapeli@iki.fi>
References: <CA+5PVA4P2avVr+m=ittQUyBou9kT2nbK0-Jeo+3coAFyQXTT_A@mail.gmail.com>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mikko.rapeli-X3B1VOXEql0@public.gmane.org
To: Stephen Hemminger <shemming-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+5PVA4P2avVr+m=ittQUyBou9kT2nbK0-Jeo+3coAFyQXTT_A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

glibc's net/if.h contains copies of definitions from linux/if.h and these
conflict and cause build failures if both files are included by application
source code. Changes in uapi headers, which fixed header file dependencies to
include linux/if.h when it was needed, made the net/if.h and linux/if.h
incompatibilities visible as build failures for userspace applications
like iproute2.

This patch fixes the cases where glibc net/if.h is included before linux/if.h
by using the linux/libc-compat.h approach.

The cases where linux/if.h is included before net/if.h need a similar fix in
the glibc side, or the order of include files can be changed userspace
code as a workaround.

This change was tested in x86 userspace after 'make headers_install' and
combining these headers with plain glibc and gcc headers. The test included
not just net/if.h but all compiling glibc headers with linux/if.h and it
compiles now without errors and warnings.

 $ cat usr/libc_conflict_test/libc_headers.h
 #include <aio.h>
 #include <aliases.h>
 #include <alloca.h>
 #include <argp.h>
 #include <argz.h>
 #include <ar.h>
 //these conflict with each other
 // #include <arpa/ftp.h>
 // #include <arpa/inet.h>
 // #include <arpa/nameser_compat.h>
 // #include <arpa/nameser.h>
 // #include <arpa/telnet.h>
 // #include <arpa/tftp.h>
 #include <assert.h>
 #include <byteswap.h>
 #include <complex.h>
 #include <cpio.h>
 #include <crypt.h>
 #include <ctype.h>
 #include <dirent.h>
 #include <dlfcn.h>
 #include <elf.h>
 #include <endian.h>
 #include <envz.h>
 #include <err.h>
 #include <errno.h>
 #include <error.h>
 #include <execinfo.h>
 #include <fcntl.h>
 #include <features.h>
 #include <fenv.h>
 #include <fmtmsg.h>
 #include <fnmatch.h>
 #include <fstab.h>
 #include <fts.h>
 #include <ftw.h>
 #include <_G_config.h>
 #include <gconv.h>
 #include <getopt.h>
 #include <glob.h>
 #include <gnu-versions.h>
 #include <grp.h>
 #include <gshadow.h>
 #include <iconv.h>
 #include <ifaddrs.h>
 #include <inttypes.h>
 #include <langinfo.h>
 #include <lastlog.h>
 #include <libgen.h>
 #include <libintl.h>
 #include <libio.h>
 #include <limits.h>
 #include <link.h>
 #include <locale.h>
 #include <malloc.h>
 #include <math.h>
 #include <mcheck.h>
 #include <memory.h>
 #include <mntent.h>
 #include <monetary.h>
 #include <mqueue.h>
 #include <netash/ash.h>
 #include <netatalk/at.h>
 #include <netax25/ax25.h>
 #include <netdb.h>
 #include <neteconet/ec.h>
 #include <net/ethernet.h>
 #include <net/if_arp.h>
 #include <net/if.h>
 #include <net/if_packet.h>
 #include <net/if_ppp.h>
 #include <net/if_shaper.h>
 #include <net/if_slip.h>
 #include <netinet/ether.h>
 #include <netinet/icmp6.h>
 #include <netinet/if_ether.h>
 #include <netinet/if_fddi.h>
 #include <netinet/if_tr.h>
 #include <netinet/igmp.h>
 #include <netinet/in.h>
 #include <netinet/in_systm.h>
 #include <netinet/ip6.h>
 #include <netinet/ip.h>
 #include <netinet/ip_icmp.h>
 #include <netinet/tcp.h>
 #include <netinet/udp.h>
 #include <netipx/ipx.h>
 #include <netiucv/iucv.h>
 #include <netpacket/packet.h>
 #include <net/ppp-comp.h>
 #include <net/ppp_defs.h>
 #include <netrom/netrom.h>
 #include <netrose/rose.h>
 #include <net/route.h>
 #include <nl_types.h>
 #include <nss.h>
 #include <obstack.h>
 #include <paths.h>
 #include <poll.h>
 #include <printf.h>
 #include <protocols/routed.h>
 #include <protocols/rwhod.h>
 // conflicts with arap headers
 //#include <protocols/talkd.h>
 #include <protocols/timed.h>
 #include <pthread.h>
 #include <pty.h>
 #include <pwd.h>
 #include <re_comp.h>
 #include <regex.h>
 // conflicts with arpa headers
 //#include <resolv.h>
 #include <sched.h>
 #include <scsi/scsi.h>
 #include <scsi/scsi_ioctl.h>
 #include <scsi/sg.h>
 #include <search.h>
 #include <semaphore.h>
 #include <setjmp.h>
 #include <sgtty.h>
 #include <shadow.h>
 #include <signal.h>
 #include <spawn.h>
 #include <stab.h>
 #include <stdc-predef.h>
 #include <stdint.h>
 #include <stdio_ext.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <strings.h>
 #include <stropts.h>
 #include <syscall.h>
 #include <sysexits.h>
 #include <syslog.h>
 #include <tar.h>
 #include <termio.h>
 #include <termios.h>
 #include <tgmath.h>
 #include <thread_db.h>
 #include <time.h>
 #include <ttyent.h>
 #include <uchar.h>
 #include <ucontext.h>
 #include <ulimit.h>
 #include <unistd.h>
 #include <ustat.h>
 #include <utime.h>
 #include <utmp.h>
 #include <utmpx.h>
 #include <values.h>
 #include <wait.h>
 #include <wchar.h>
 #include <wctype.h>
 #include <wordexp.h>
 #include <xlocale.h>

 $ cat iproute2_bug.h
 #include <libc_headers.h>
 #include <linux/if.h>

 $ cc -Wall -c -nostdinc -I ../include/ -I /usr/lib/gcc/i586-linux-gnu/5/include -I /usr/lib/gcc/i586-linux-gnu/5/include-fixed -I . -I /home/mcfrisk/src/linux-2.6/usr/headers_compile_test_include.ddxtNf -I /home/mcfrisk/src/linux-2.6/usr/headers_compile_test_include.ddxtNf/i586-linux-gnu -o /dev/null ./iproute2_bug.h

Reported-by: Stephen Hemminger <shemming-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
Reported-by: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
---
 include/uapi/linux/if.h          | 21 +++++++++++++++++++++
 include/uapi/linux/libc-compat.h | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394..5a07a67 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -19,11 +19,15 @@
 #ifndef _LINUX_IF_H
 #define _LINUX_IF_H
 
+#include <linux/libc-compat.h>          /* for compatibility with glibc */
 #include <linux/types.h>		/* for "__kernel_caddr_t" et al	*/
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/compiler.h>		/* for "__user" et al           */
 
+/* For compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFNAMSIZ
 #define	IFNAMSIZ	16
+#endif /* __UAPI_DEF_IF_IFNAMSIZ */
 #define	IFALIASZ	256
 #include <linux/hdlc/ioctl.h>
 
@@ -68,6 +72,8 @@
  * @IFF_ECHO: echo sent packets. Volatile.
  */
 enum net_device_flags {
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
 	IFF_UP				= 1<<0,  /* sysfs */
 	IFF_BROADCAST			= 1<<1,  /* volatile */
 	IFF_DEBUG			= 1<<2,  /* sysfs */
@@ -84,11 +90,14 @@ enum net_device_flags {
 	IFF_PORTSEL			= 1<<13, /* sysfs */
 	IFF_AUTOMEDIA			= 1<<14, /* sysfs */
 	IFF_DYNAMIC			= 1<<15, /* sysfs */
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
 	IFF_LOWER_UP			= 1<<16, /* volatile */
 	IFF_DORMANT			= 1<<17, /* volatile */
 	IFF_ECHO			= 1<<18, /* volatile */
 };
 
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_NET_DEVICE_FLAGS
 #define IFF_UP				IFF_UP
 #define IFF_BROADCAST			IFF_BROADCAST
 #define IFF_DEBUG			IFF_DEBUG
@@ -105,6 +114,8 @@ enum net_device_flags {
 #define IFF_PORTSEL			IFF_PORTSEL
 #define IFF_AUTOMEDIA			IFF_AUTOMEDIA
 #define IFF_DYNAMIC			IFF_DYNAMIC
+#endif /* __UAPI_DEF_IF_NET_DEVICE_FLAGS */
+
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
@@ -166,6 +177,8 @@ enum {
  *	being very small might be worth keeping for clean configuration.
  */
 
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFMAP
 struct ifmap {
 	unsigned long mem_start;
 	unsigned long mem_end;
@@ -175,6 +188,7 @@ struct ifmap {
 	unsigned char port;
 	/* 3 bytes spare */
 };
+#endif /* __UAPI_DEF_IF_IFMAP */
 
 struct if_settings {
 	unsigned int type;	/* Type of physical device or protocol */
@@ -200,6 +214,8 @@ struct if_settings {
  * remainder may be interface specific.
  */
 
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFREQ
 struct ifreq {
 #define IFHWADDRLEN	6
 	union
@@ -223,6 +239,7 @@ struct ifreq {
 		struct	if_settings ifru_settings;
 	} ifr_ifru;
 };
+#endif /* __UAPI_DEF_IF_IFREQ */
 
 #define ifr_name	ifr_ifrn.ifrn_name	/* interface name 	*/
 #define ifr_hwaddr	ifr_ifru.ifru_hwaddr	/* MAC address 		*/
@@ -249,6 +266,8 @@ struct ifreq {
  * must know all networks accessible).
  */
 
+/* for compatibility with glibc net/if.h */
+#if __UAPI_DEF_IF_IFCONF
 struct ifconf  {
 	int	ifc_len;			/* size of buffer	*/
 	union {
@@ -256,6 +275,8 @@ struct ifconf  {
 		struct ifreq __user *ifcu_req;
 	} ifc_ifcu;
 };
+#endif /* __UAPI_DEF_IF_IFCONF */
+
 #define	ifc_buf	ifc_ifcu.ifcu_buf		/* buffer address	*/
 #define	ifc_req	ifc_ifcu.ifcu_req		/* array of structures	*/
 
diff --git a/include/uapi/linux/libc-compat.h b/include/uapi/linux/libc-compat.h
index 7d024ce..9211e52 100644
--- a/include/uapi/linux/libc-compat.h
+++ b/include/uapi/linux/libc-compat.h
@@ -51,6 +51,32 @@
 /* We have included glibc headers... */
 #if defined(__GLIBC__)
 
+/* Coordinate with glibc net/if.h header. */
+#if defined(_NET_IF_H)
+
+/* GLIBC headers included first so don't define anything
+ * that would already be defined. */
+
+#define __UAPI_DEF_IF_IFCONF 0
+#define __UAPI_DEF_IF_IFMAP 0
+#define __UAPI_DEF_IF_IFNAMSIZ 0
+#define __UAPI_DEF_IF_IFREQ 0
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 0
+
+#else /* _NET_IF_H */
+
+/* Linux headers included first, and we must define everything
+ * we need. The expectation is that glibc will check the
+ * __UAPI_DEF_* defines and adjust appropriately. */
+
+#define __UAPI_DEF_IF_IFCONF 1
+#define __UAPI_DEF_IF_IFMAP 1
+#define __UAPI_DEF_IF_IFNAMSIZ 1
+#define __UAPI_DEF_IF_IFREQ 1
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 1
+
+#endif /* _NET_IF_H */
+
 /* Coordinate with glibc netinet/in.h header. */
 #if defined(_NETINET_IN_H)
 
@@ -117,6 +143,13 @@
  * that we need. */
 #else /* !defined(__GLIBC__) */
 
+/* Definitions for if.h */
+#define __UAPI_DEF_IF_IFCONF 1
+#define __UAPI_DEF_IF_IFMAP 1
+#define __UAPI_DEF_IF_IFNAMSIZ 1
+#define __UAPI_DEF_IF_IFREQ 1
+#define __UAPI_DEF_IF_NET_DEVICE_FLAGS 1
+
 /* Definitions for in.h */
 #define __UAPI_DEF_IN_ADDR		1
 #define __UAPI_DEF_IN_IPPROTO		1
-- 
2.7.0.rc3
