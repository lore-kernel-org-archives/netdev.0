From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 17:51:45 +0200
Message-ID: <1288021905.2826.142.camel@edumazet-laptop>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de>
	 <4CC5A301.1080606@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <arnd@arndnet.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CC5A301.1080606@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 25 octobre 2010 =C3=A0 10:32 -0500, Larry Finger a =C3=A9crit =
:
> On 10/25/2010 09:41 AM, Arnd Hannemann wrote:
> > On todays linus tree the following compile error happened to me:
> >=20
> >   CC [M]  drivers/net/wireless/b43legacy/xmit.o
> > In file included from include/net/dst.h:11,
> >                  from drivers/net/wireless/b43legacy/xmit.c:31:
> > include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__=
attribute__' before '____cacheline_aligned_in_smp'
> > include/net/dst_ops.h: In function 'dst_entries_get_fast':
> > include/net/dst_ops.h:33: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
> > include/net/dst_ops.h: In function 'dst_entries_get_slow':
> > include/net/dst_ops.h:41: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
> > include/net/dst_ops.h: In function 'dst_entries_add':
> > include/net/dst_ops.h:49: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
> > include/net/dst_ops.h: In function 'dst_entries_init':
> > include/net/dst_ops.h:55: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
> > include/net/dst_ops.h: In function 'dst_entries_destroy':
> > include/net/dst_ops.h:60: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
> > make[4]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
> > make[3]: *** [drivers/net/wireless/b43legacy] Error 2
> > make[2]: *** [drivers/net/wireless] Error 2
> > make[1]: *** [drivers/net] Error 2
> > make: *** [drivers] Error 2
> >=20
> > This patch fixes this issue by adding "linux/cache.h" as an include=
 to
> > "include/net/dst_ops.h".
>=20
> Strange. Compiling b43legacy from the linux-2.6.git tree (git describ=
e is
> v2.6.36-4464-g229aebb) works fine on x86_64. I wonder what is differe=
nt.

Well, x86_64 must include cache.h, this is probably why I missed it in
my build tests.

I wonder also why #include <net/dst.h> is needed at all in this
driver...

diff --git a/drivers/net/wireless/b43legacy/xmit.c
b/drivers/net/wireless/b43legacy/xmit.c
index 7d177d9..a261aec 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -28,8 +28,6 @@
=20
 */
=20
-#include <net/dst.h>
-
 #include "xmit.h"
 #include "phy.h"
 #include "dma.h"
