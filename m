From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [PATCH] clean up net/802/Makefile (large version)
Date: Thu, 20 Mar 2003 23:35:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320223542.GC13641@wohnheim.fh-wedel.de>
References: <20030320223329.GB13641@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20030320223329.GB13641@wohnheim.fh-wedel.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This one tries to clean up the other code as well.

J=F6rn

--=20
The cheapest, fastest and most reliable components of a computer
system are those that aren't there.
-- Gordon Bell, DEC labratories

--- linux-2.4.20/net/802/Makefile	Sat Aug  3 02:39:46 2002
+++ linux-2.4.20/net/802/Makefile.2	Thu Mar 20 23:26:22 2003
@@ -11,48 +11,26 @@
=20
 export-objs =3D llc_macinit.o p8022.o psnap.o
=20
+snap-objs =3D p8022.o psnap.o
+
 obj-y	=3D p8023.o
=20
 obj-$(CONFIG_SYSCTL) +=3D sysctl_net_802.o
-obj-$(CONFIG_LLC) +=3D llc_sendpdu.o llc_utility.o cl2llc.o llc_macinit.=
o
-ifeq ($(CONFIG_SYSCTL),y)
-obj-y +=3D sysctl_net_802.o
-endif
-
-ifeq ($(CONFIG_LLC),y)
-subdir-y +=3D transit
-obj-y +=3D llc_sendpdu.o llc_utility.o cl2llc.o llc_macinit.o
-SNAP =3D y
-endif
-
-ifdef CONFIG_TR
-obj-y +=3D tr.o
-	SNAP=3Dy
-endif
-
-ifdef CONFIG_NET_FC
-obj-y +=3D fc.o
-endif
-
-ifdef CONFIG_FDDI
-obj-y +=3D fddi.o
-endif
-
-ifdef CONFIG_HIPPI
-obj-y +=3D hippi.o
-endif
-
-ifdef CONFIG_IPX
-	SNAP=3Dy
-endif
-
-ifdef CONFIG_ATALK
-	SNAP=3Dy
-endif
-
-ifeq ($(SNAP),y)
-obj-y +=3D p8022.o psnap.o
-endif
+obj-$(CONFIG_LLC) +=3D llc_sendpdu.o llc_utility.o cl2llc.o llc_macinit.=
o $(snap-objs)
+
+subdir-$(CONFIG_LLC) +=3D transit
+
+obj-$(CONFIG_TR) +=3D tr.o $(snap-objs)
+
+obj-$(CONFIG_NET_FC) +=3D fc.o
+
+obj-$(CONFIG_FDDI) +=3D fddi.o
+
+obj-$(CONFIG_HIPPI) +=3D hippi.o
+
+obj-$(CONFIG_IPX) +=3D $(snap-objs)
+
+obj-$(CONFIG_ATALK) +=3D $(snap-objs)
=20
 include $(TOPDIR)/Rules.make
=20
