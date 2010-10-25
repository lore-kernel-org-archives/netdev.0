From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 13:11:47 -0500
Message-ID: <4CC5C863.9070801@lwfinger.net>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de>	 <4CC5A301.1080606@lwfinger.net> <1288021905.2826.142.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1288021905.2826.142.camel@edumazet-laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/25/2010 10:51 AM, Eric Dumazet wrote:
> Le lundi 25 octobre 2010 =C3=A0 10:32 -0500, Larry Finger a =C3=A9cri=
t :
>> On 10/25/2010 09:41 AM, Arnd Hannemann wrote:
>>> On todays linus tree the following compile error happened to me:
>>>
>>>   CC [M]  drivers/net/wireless/b43legacy/xmit.o
>>> In file included from include/net/dst.h:11,
>>>                  from drivers/net/wireless/b43legacy/xmit.c:31:
>>> include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__=
attribute__' before '____cacheline_aligned_in_smp'
>>> include/net/dst_ops.h: In function 'dst_entries_get_fast':
>>> include/net/dst_ops.h:33: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
>>> include/net/dst_ops.h: In function 'dst_entries_get_slow':
>>> include/net/dst_ops.h:41: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
>>> include/net/dst_ops.h: In function 'dst_entries_add':
>>> include/net/dst_ops.h:49: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
>>> include/net/dst_ops.h: In function 'dst_entries_init':
>>> include/net/dst_ops.h:55: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
>>> include/net/dst_ops.h: In function 'dst_entries_destroy':
>>> include/net/dst_ops.h:60: error: 'struct dst_ops' has no member nam=
ed 'pcpuc_entries'
>>> make[4]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
>>> make[3]: *** [drivers/net/wireless/b43legacy] Error 2
>>> make[2]: *** [drivers/net/wireless] Error 2
>>> make[1]: *** [drivers/net] Error 2
>>> make: *** [drivers] Error 2
>>>
>>> This patch fixes this issue by adding "linux/cache.h" as an include=
 to
>>> "include/net/dst_ops.h".
>>
>> Strange. Compiling b43legacy from the linux-2.6.git tree (git descri=
be is
>> v2.6.36-4464-g229aebb) works fine on x86_64. I wonder what is differ=
ent.
>=20
> Well, x86_64 must include cache.h, this is probably why I missed it i=
n
> my build tests.
>=20
> I wonder also why #include <net/dst.h> is needed at all in this
> driver...
>=20
> diff --git a/drivers/net/wireless/b43legacy/xmit.c
> b/drivers/net/wireless/b43legacy/xmit.c
> index 7d177d9..a261aec 100644
> --- a/drivers/net/wireless/b43legacy/xmit.c
> +++ b/drivers/net/wireless/b43legacy/xmit.c
> @@ -28,8 +28,6 @@
> =20
>  */
> =20
> -#include <net/dst.h>
> -
>  #include "xmit.h"
>  #include "phy.h"
>  #include "dma.h"

I have no idea why that header was included - likely historical in the
transformation from bcm43xx to b43legacy. For completeness, there are 2=
 more
places to change:

Index: linux-2.6/drivers/net/wireless/b43legacy/dma.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/wireless/b43legacy/dma.c
+++ linux-2.6/drivers/net/wireless/b43legacy/dma.c
@@ -38,7 +38,6 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
-#include <net/dst.h>

 /* 32bit DMA ops. */
 static
Index: linux-2.6/drivers/net/wireless/b43legacy/main.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/wireless/b43legacy/main.c
+++ linux-2.6/drivers/net/wireless/b43legacy/main.c
@@ -41,7 +41,6 @@
 #include <linux/skbuff.h>
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
-#include <net/dst.h>
 #include <asm/unaligned.h>

 #include "b43legacy.h"
Index: linux-2.6/drivers/net/wireless/b43legacy/xmit.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/wireless/b43legacy/xmit.c
+++ linux-2.6/drivers/net/wireless/b43legacy/xmit.c
@@ -28,8 +28,6 @@

 */

-#include <net/dst.h>
