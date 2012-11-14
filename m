From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on it
Date: Wed, 14 Nov 2012 01:08:00 -0500
Message-ID: <20121114060759.GA17128@windriver.com>
References: <1352846164.17444.16.camel@joe-AO722>
 <20121113.182215.2003568859498195687.davem@davemloft.net>
 <CAP=VYLqiLpVn99bp08gkSQ+jLFiw8T7vsohJ6e+TdzOtyDwKBQ@mail.gmail.com>
 <20121113.204437.197646115673556624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joe@perches.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:36392 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab2KNGIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 01:08:18 -0500
Content-Disposition: inline
In-Reply-To: <20121113.204437.197646115673556624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on it]=
 On 13/11/2012 (Tue 20:44) David Miller wrote:

>=20
> Paul, you can't have HTML content to the list and one of your MIME
> sections was HTML, so it was rejected by vger's filters.
>=20
> Please repost with the HTML stuff removed.

Ah crap.  I'd replied via gmail ; today and occasionally in the past as
a convenient short cut when not reading netdev with a "normal" MUA.  An=
d
this is not the 1st time gmail has randomly decided to be "helpful" by
mangling plain text like this.  Well, I'll be having no more of that BS=
=2E

Sorry about that; I know you don't need the extra stupidity to deal
with, esp. at this point in time.  Original plain text follows, courtes=
y
of reliable 1990's MUA technology -- the pull details remain unchanged.

Paul.
--

On Tue, Nov 13, 2012 at 6:22 PM, David Miller <davem@davemloft.net> wro=
te:

>From: Joe Perches <joe@perches.com>
>Date: Tue, 13 Nov 2012 14:36:04 -0800

>> Remove wanrouter as it's obsolete and has not been updated
>> by sangoma since 2.4.3 or so and it's not used anymore.
>>
>> Remove obsolete cyclomx drivers.
>> Update files that include now deleted wanrouter bits.
>>
>> Signed-off-by: Joe Perches <joe@perches.com>

>This breaks the build.

>drivers/isdn/i4l/isdn_x25iface.c:33:18: error: field =E2=80=98state=E2=
=80=99 has incomplete type
>drivers/isdn/i4l/isdn_x25iface.c: In function =E2=80=98isdn_x25iface_p=
roto_new=E2=80=99:
>drivers/isdn/i4l/isdn_x25iface.c:89:16: error: =E2=80=98WAN_UNCONFIGUR=
ED=E2=80=99 undeclared (first use in this function)

[...]

I'd hate to see a garbage collection miss out from integration due to
wider testing, so I've taken Joe's commit, put it on today's net-next
and made the following changes:

  -keep magic number references but mark them obsolete (nobody asked fo=
r
   this, but it made sense to me).

  -keep the wanrouter.h (uapi and kernel-centric one) files, but with
   only the X.25 bits that caused build failures.  I have trimmed the e=
num
   to just the bits that were used.  Obvious build failures like davem
   reported aside, I was concerned that userspace might reference the
   headers (got caught on this for my token-ring deletion).  I did not =
find
   any userspace uses, but it was packaged with most distro's libc head=
er
   content, so who knows?  As I did run into this with the token ring
   delete, so this is the safer route here -- i.e. leaving a skeleton
   header.

I don't want to spam everyone with another giant patch, so note that a
diff from Joe's original and my amendment is shown below (warning - cut
and paste damaged ; not that anyone sane should, but don't try and appl=
y
this delta; it is for review purposes only -- and all lines with "+" ar=
e
just restoration of what lines were already there).

=46or the folks well adapted to git already, I've pushed an equivalent
branch that I have done the build testing of an x86_64 allyesconfig and
allmodconfig, and they compile OK.  This is based on the net-next of
today:

The following changes since commit bf0098f22ca7b59e8844ac6882bbae230d34=
b98d:

  ARM: net: bpf_jit_32: add VLAN instructions for BPF JIT (2012-11-13 1=
8:21:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git wanrout=
er-delete

for you to fetch changes up to 148233ec812733b88ad4d341a07e23229ed02810=
:

  wanrouter: Remove it and the drivers that depend on it (2012-11-13 19=
:53:15 -0500)

----------------------------------------------------------------
Joe Perches (1):
      wanrouter: Remove it and the drivers that depend on it

 Documentation/ioctl/ioctl-number.txt |    2 +-
 Documentation/magic-number.txt       |    2 +-
 Documentation/zh_CN/magic-number.txt |    2 +-
 drivers/isdn/i4l/isdn_x25iface.h     |    1 -
 drivers/net/wan/Kconfig              |   54 --
 drivers/net/wan/Makefile             |    5 -
 drivers/net/wan/cycx_drv.c           |  569 ------------
 drivers/net/wan/cycx_main.c          |  346 --------
 drivers/net/wan/cycx_x25.c           | 1602 --------------------------=
--------
 include/linux/cyclomx.h              |   77 --
 include/linux/cycx_drv.h             |   64 --
 include/linux/wanrouter.h            |  127 +--
 include/uapi/linux/Kbuild            |    1 -
 include/uapi/linux/wanrouter.h       |  443 +---------
 net/Kconfig                          |    1 -
 net/Makefile                         |    1 -
 net/socket.c                         |    1 -
 net/wanrouter/Kconfig                |   27 -
 net/wanrouter/Makefile               |    7 -
 net/wanrouter/patchlevel             |    1 -
 net/wanrouter/wanmain.c              |  782 -----------------
 net/wanrouter/wanproc.c              |  380 --------
 22 files changed, 11 insertions(+), 4484 deletions(-)
 delete mode 100644 drivers/net/wan/cycx_drv.c
 delete mode 100644 drivers/net/wan/cycx_main.c
 delete mode 100644 drivers/net/wan/cycx_x25.c
 delete mode 100644 include/linux/cyclomx.h
 delete mode 100644 include/linux/cycx_drv.h
 delete mode 100644 net/wanrouter/Kconfig
 delete mode 100644 net/wanrouter/Makefile
 delete mode 100644 net/wanrouter/patchlevel
 delete mode 100644 net/wanrouter/wanmain.c
 delete mode 100644 net/wanrouter/wanproc.c

 -- below not for application, review only ; delta diff follows --

diff --git a/Documentation/ioctl/ioctl-number.txt b/Documentation/ioctl=
/ioctl-number.txt
index 028a034..bb8315a 100644
--- a/Documentation/ioctl/ioctl-number.txt
+++ b/Documentation/ioctl/ioctl-number.txt
@@ -179,6 +179,7 @@ Code  Seq#(hex)     Include File            Comment=
s

 'V'    C0      media/davinci/vpfe_capture.h    conflict!
 'V'    C0      media/si4713.h          conflict!
 'W'    00-1F   linux/watchdog.h        conflict!
+'W'    00-1F   linux/wanrouter.h       conflict!               (pre 3.=
8)

 'W'    00-3F   sound/asound.h          conflict!
 'X'    all     fs/xfs/xfs_fs.h         conflict!
                and fs/xfs/linux-2.6/xfs_ioctl32.h
diff --git a/Documentation/magic-number.txt b/Documentation/magic-numbe=
r.txt
index 0c39e72..851e447 100644
--- a/Documentation/magic-number.txt
+++ b/Documentation/magic-number.txt
@@ -122,6 +122,7 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache       =
 mm/slab.c

 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ub=
d_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_aud=
io.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.=
c
+ROUTER_MAGIC          0x524d4157  wan_device        [in wanrouter.h pr=
e 3.8]

 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/confi=
g.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/=
asm/sn/gda.h
diff --git a/Documentation/zh_CN/magic-number.txt b/Documentation/zh_CN=
/magic-number.txt
index 51b7e15..5ab5271 100644
--- a/Documentation/zh_CN/magic-number.txt
+++ b/Documentation/zh_CN/magic-number.txt
@@ -122,6 +122,7 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache       =
 mm/slab.c

 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ub=
d_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_aud=
io.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.=
c
+ROUTER_MAGIC          0x524d4157  wan_device        [in wanrouter.h pr=
e 3.8]

 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/confi=
g.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/=
asm/sn/gda.h
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x=
25iface.c
index d00c86d..e2d4e58 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -21,6 +21,7 @@

 #include <linux/netdevice.h>
 #include <linux/concap.h>
 #include <linux/slab.h>
+#include <linux/wanrouter.h>
 #include <net/x25device.h>
 #include "isdn_x25iface.h"
=20
diff --git a/include/linux/wanrouter.h b/include/linux/wanrouter.h
new file mode 100644
index 0000000..8198a63
--- /dev/null
+++ b/include/linux/wanrouter.h
@@ -0,0 +1,10 @@
+/*
+ * wanrouter.h Legacy declarations kept around until X25 is removed
+ */
+
+#ifndef        _ROUTER_H
+#define        _ROUTER_H
+
+#include <uapi/linux/wanrouter.h>
+
+#endif /* _ROUTER_H */
diff --git a/include/uapi/linux/wanrouter.h b/include/uapi/linux/wanrou=
ter.h
new file mode 100644
index 0000000..498d6c1
--- /dev/null
+++ b/include/uapi/linux/wanrouter.h
@@ -0,0 +1,17 @@
+/*
+ * wanrouter.h Legacy declarations kept around until X25 is removed
+ */
+
+#ifndef _UAPI_ROUTER_H
+#define _UAPI_ROUTER_H
+
+/* 'state' defines */
+enum wan_states
+{
+       WAN_UNCONFIGURED,       /* link/channel is not configured */
+       WAN_DISCONNECTED,       /* link/channel is disconnected */
+       WAN_CONNECTING,         /* connection is in progress */
+       WAN_CONNECTED           /* link/channel is operational */
+};
+
+#endif /* _UAPI_ROUTER_H */
