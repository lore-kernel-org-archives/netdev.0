From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 2/16] e1000: Fix msec-delay definition
 to use msleep (fwd)
Date: Wed, 27 Apr 2005 11:20:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271119590.17876-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix msec-delay definition in e1000_osdep.h to use msleep

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/e1000/e1000_osdep.h net-drivers-2.6/=
drivers/net/e1000.new/e1000_osdep.h
--- net-drivers-2.6/drivers/net/e1000/e1000_osdep.h=A0=A0=A0=A0 2005-04-1=
1 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_osdep.h 2005-04-11 02:22:=
29.000000000 -0700
@@ -42,7 +42,12 @@
=A0#include <linux/sched.h>
=A0
=A0#ifndef msec_delay
-#define msec_delay(x) msleep(x)
+#define msec_delay(x)=A0 do { if(in_interrupt()) { \
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 /* Don't mdelay in interrupt context! */ \
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 BUG(); \
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 } else { =
\
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=
=A0=A0=A0=A0 msleep(x); \
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 } } while=
(0)
=A0
=A0/* Some workarounds require millisecond delays and are run during inte=
rrupt
=A0 * context.=A0 Most notably, when establishing link, the phy may need =
tweaking
