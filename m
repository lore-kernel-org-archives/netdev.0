From: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>
Subject: [PATCH] [resend]The kernel gets no IP from some DHCP servers, 2.6.24
Date: Wed, 27 Feb 2008 13:23:48 +0100
Message-ID: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<ebiederman@lnxi.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757352AbYB0MYI@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wonder why there is no feedback to the sugested DHCP patch to
linux/net/ipv4/ipconfig.c Am I wrong with the interpretation of
RFC2131 section about the contents of a clients DHCPDISCOVER
packet? If not I would assume that the behaviour of the kernels
DHCP should be changed.

Thanks,
Marcel

the original mail:
http://lkml.org/lkml/2008/2/21/171

=3D=3D=3D=3D=3D=3D original patch =3D=3D=3D=3D=3D=3D=3D=3D=3D
This patch fixes a DHCP issue of the kernel: some DHCP servers
(i.e. in the Linksys WRT54Gv5) are very strict about the contents=20
of the DHCPDISCOVER packet they receive from clients. Table 5 in RFC213=
1
page 36 requests the fields 'ciaddr' and 'siaddr' MUST be set to '0'.
These DHCP servers ignore Linux kernel's DHCP discovery packets with th=
ese two
fields set to '255.255.255.255' (in contrast to popular DHCP clients, s=
uch as
'dhclient' or 'udhcpc'). This leads to a not booting system.
I tested this on a ARM embedded device mounting rootfs over NFS obtaini=
ng
its IP from a Linksys WRT54Gv5 Router running VxWorks and a PC based Se=
rver
running a Linux. Changing the two fields to '0.0.0.0' worked.

Please CC me personaly when answering this message.

Thanks,
Marcel

--- linux-2.6.24.2/net/ipv4/ipconfig.c	2008-02-21 15:27:47.250890963 +0=
100
+++ linux/net/ipv4/ipconfig.c	2008-02-21 15:36:12.686735925 +0100
@@ -29,6 +29,10 @@
  *
  *  Multiple Nameservers in /proc/net/pnp
  *              --  Josef Siemes <jsiemes@web.de>, Aug 2002
+ *
+ *  Bugfix: Not getting an IP from some DHCP servers: RFC2131 page 36
+ *  Table 5 requests DHCPDISCOVER fields ciaddr and siaddr MUST be '0'=
=2E
+ *              -- marcel.wappler@bridgeco.net
  */
=20
 #include <linux/types.h>
@@ -103,6 +107,7 @@
 					   - '3' from resolv.h */
=20
 #define NONE __constant_htonl(INADDR_NONE)
+#define ZERO __constant_htonl(((unsigned long int) 0x00000000))
=20
 /*
  * Public IP configuration
@@ -740,8 +745,8 @@
 		b->htype =3D dev->type; /* can cause undefined behavior */
 	}
 	b->hlen =3D dev->addr_len;
-	b->your_ip =3D NONE;
-	b->server_ip =3D NONE;
+	b->your_ip =3D ZERO;
+	b->server_ip =3D ZERO;
 	memcpy(b->hw_addr, dev->dev_addr, dev->addr_len);
 	b->secs =3D htons(jiffies_diff / HZ);
 	b->xid =3D d->xid;

--
Marcel Wappler
Bridgeco AG
CH-8600 D=FCbendorf
Switzerland
