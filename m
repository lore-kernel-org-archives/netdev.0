From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.4 4/16] e1000:Enable polling before
 enabling interrupts (fwd)
Date: Wed, 27 Apr 2005 11:04:06 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271103450.17397-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Enable polling before enabling interrupts -- avoids (in NAPI mode) enteri=
ng the ISR and returning without doing any work because polling is not en=
abled.
[romieu@fr.zoriel.com]

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/d=
rivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c=A0=A0=A0=A0=A0 2005-04=
-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c=A0 2005-04-12 23:0=
0:55.000000000 -0700
@@ -325,11 +325,12 @@ e1000_up(struct e1000_adapter *adapter)
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 return err;
=A0
=A0=A0=A0=A0=A0=A0=A0 mod_timer(&adapter->watchdog_timer, jiffies);
-=A0=A0=A0=A0=A0=A0 e1000_irq_enable(adapter);
=A0
=A0#ifdef CONFIG_E1000_NAPI
=A0=A0=A0=A0=A0=A0=A0 netif_poll_enable(netdev);
=A0#endif
+=A0=A0=A0=A0=A0=A0 e1000_irq_enable(adapter);
+
=A0=A0=A0=A0=A0=A0=A0 return 0;
=A0}
=A0
