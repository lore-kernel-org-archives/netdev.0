From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm snapshot broken-out-2007-04-07-03-27.tar.gz uploaded
Date: Sat, 7 Apr 2007 13:10:00 -0700
Message-ID: <20070407131000.e3007eac.akpm@linux-foundation.org>
References: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net>
	<4617F455.2050401@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965712AbXDGUKi@vger.kernel.org>
In-Reply-To: <4617F455.2050401@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 07 Apr 2007 21:43:17 +0200 Michal Piotrowski <michal.k.k.piotro=
wski@gmail.com> wrote:

> akpm@linux-foundation.org napisa=C5=82(a):
> > The mm snapshot broken-out-2007-04-07-03-27.tar.gz has been uploade=
d to
> >=20
> >    ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/broken-out-=
2007-04-07-03-27.tar.gz
> >=20
> > It contains the following patches against 2.6.21-rc6:
>=20
> suspend-to-disk doesn't work when pktgen module is loaded.
>=20
> Stopping kernel threads timed out after 20 seconds (2 tasks refusing =
to freeze):
>  kpktgend_0
>  kpktgend_1
> Restarting tasks ... done.
> swsusp: Basic memory bitmaps freed

This?

--- a/net/core/pktgen.c~pktgen-add-try_to_freeze
+++ a/net/core/pktgen.c
@@ -128,6 +128,7 @@
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/capability.h>
+#include <linux/freezer.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/list.h>
@@ -3325,6 +3326,8 @@ static int pktgen_thread_worker(void *ar
 			t->control &=3D ~(T_REMDEV);
 		}
=20
+		try_to_freeze();
+
 		set_current_state(TASK_INTERRUPTIBLE);
 	}
=20
_

> http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/broken-out-2=
007-04-07-03-27/mm-serialconsole2.log
>=20
> Anyway, this kernel is pretty stable :)

Is appreciated, thanks.
