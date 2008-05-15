From: Nicolas 2P <nicolas.2p.debian@free.fr>
Subject: [patch]  bondig - arp_interval with low value => Oops.
Date: Thu, 15 May 2008 22:34:59 +0200
Message-ID: <482C9E73.2040202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764563AbYEOUfb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When setting arp_interval parameter to a very low value, delta_in_ticks=
=20
for next arp might become 0, causing an infinite loop.

See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680

Same problem for miimon parameter already fixed, but fix might be=20
enhanced, by using msecs_to_jiffies() function.

Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

--- /usr/src/linux/drivers/net/bonding/bond_main_orig.c 2008-05-13=20
02:00:01.000000000 +0200
+++ /usr/src/linux/drivers/net/bonding/bond_main.c      2008-05-14=20
14:55:53.000000000 +0200
@@ -2391,7 +2391,7 @@
                 read_lock(&bond->lock);
         }

-       delay =3D ((bond->params.miimon * HZ) / 1000) ? : 1;
+       delay =3D msecs_to_jiffies(bond->params.miimon);
         read_unlock(&bond->lock);
         queue_delayed_work(bond->wq, &bond->mii_work, delay);
  }
@@ -2704,7 +2704,7 @@

         read_lock(&bond->lock);

-       delta_in_ticks =3D (bond->params.arp_interval * HZ) / 1000;
+       delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval);

         if (bond->kill_timers) {
                 goto out;
@@ -2837,7 +2837,7 @@

         read_lock(&bond->lock);

-       delta_in_ticks =3D (bond->params.arp_interval * HZ) / 1000;
+       delta_in_ticks =3D msecs_to_jiffies(bond->params.arp_interval *=
 HZ);

         if (bond->kill_timers) {
                 goto out;
