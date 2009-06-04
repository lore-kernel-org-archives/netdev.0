From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/8] add lib/gcd.c
Date: Thu, 4 Jun 2009 16:39:03 +0200
Message-ID: <200906041639.04868.florian@openwrt.org>
References: <200906041615.10467.florian@openwrt.org> <4A27DAAD.5000303@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Takashi Iwai <tiwai@suse.de>,
	Ralf Baechle <ralf@linux-mips.org>
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:51168 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199AbZFDOjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 10:39:06 -0400
In-Reply-To: <4A27DAAD.5000303@ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Le Thursday 04 June 2009 16:31:09 Sergei Shtylyov, vous avez =E9crit=A0=
:
> Hello.
>
> Florian Fainelli wrote:
> > This patch adds lib/gcd.c which contains a greatest
> > common divider implementation taken from
> > sound/core/pcm_timer.c
> >
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
>
> [...]
>
> > diff --git a/lib/gcd.c b/lib/gcd.c
> > new file mode 100644
> > index 0000000..fbf81a8
> > --- /dev/null
> > +++ b/lib/gcd.c
> > @@ -0,0 +1,20 @@
> > +#include <linux/gcd.h>
> > +#include <linux/module.h>
> > +
> > +/* Greatest common divisor */
> > +unsigned long gcd(unsigned long a, unsigned long b)
> > +{
> > +	unsigned long r;
> > +
> > +	if (a < b) {
> > +		r =3D a;
> > +		a =3D b;
> > +	b =3D r;
>
>     Fix indentation please.

=46ixed in the following version. Also putting David in copy since it
he was not in copy of the first patch and could not know why there
is a following patch on net/netfilter/ipvs/ip_vs_wrr.c to use lib/gcd.c
--
=46rom: Florian Fainelli <florian@openwrt.org>

This patch adds lib/gcd.c which contains a greatest
common divider implementation taken from
sound/core/pcm_timer.c

Changes from v1:
- fixed indentation
- use EXPORT_SYMBOL_GPL instead of EXPORT_SYMBOL as
suggested by Ralf Baechle

Signed-off-by: Florian Fainelli <florian@openwrt.org>
--
diff --git a/include/linux/gcd.h b/include/linux/gcd.h
new file mode 100644
index 0000000..69f5e8a
--- /dev/null
+++ b/include/linux/gcd.h
@@ -0,0 +1,8 @@
+#ifndef _GCD_H
+#define _GCD_H
+
+#include <linux/compiler.h>
+
+unsigned long gcd(unsigned long a, unsigned long b) __attribute_const_=
_;
+
+#endif /* _GCD_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 8ade0a7..70a9906 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -10,6 +10,9 @@ menu "Library routines"
 config BITREVERSE
 	tristate
=20
+config GCD
+	bool
+
 config GENERIC_FIND_FIRST_BIT
 	bool
=20
diff --git a/lib/Makefile b/lib/Makefile
index 33a40e4..389bdd2 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -57,6 +57,7 @@ obj-$(CONFIG_CRC_ITU_T)	+=3D crc-itu-t.o
 obj-$(CONFIG_CRC32)	+=3D crc32.o
 obj-$(CONFIG_CRC7)	+=3D crc7.o
 obj-$(CONFIG_LIBCRC32C)	+=3D libcrc32c.o
+obj-$(CONFIG_GCD)	+=3D gcd.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) +=3D genalloc.o
=20
 obj-$(CONFIG_ZLIB_INFLATE) +=3D zlib_inflate/
diff --git a/lib/gcd.c b/lib/gcd.c
new file mode 100644
index 0000000..6634741
--- /dev/null
+++ b/lib/gcd.c
@@ -0,0 +1,20 @@
+#include <linux/gcd.h>
+#include <linux/module.h>
+
+/* Greatest common divisor */
+unsigned long gcd(unsigned long a, unsigned long b)
+{
+	unsigned long r;
+
+	if (a < b) {
+		r =3D a;
+		a =3D b;
+		b =3D r;
+	}
+	while ((r =3D a % b) !=3D 0) {
+		a =3D b;
+		b =3D r;
+	}
+	return b;
+}
+EXPORT_SYMBOL_GPL(gcd);
