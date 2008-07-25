From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Fri, 25 Jul 2008 18:09:35 +0100
Message-ID: <20080725180935.5bd02bf5@lxorguk.ukuu.org.uk>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
	<20080721191519.GA15843@elte.hu>
	<20080721214258.787a67ca@lxorguk.ukuu.org.uk>
	<20080722072334.GA25241@elte.hu>
	<48865899.3030209@garzik.org>
	<20080723104520.GA20672@elte.hu>
	<20080724052603.GA8744@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:56760 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751440AbYGYRac convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 13:30:32 -0400
In-Reply-To: <20080724052603.GA8744@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 07:26:03 +0200
Ingo Molnar <mingo@elte.hu> wrote:

>=20
> not sure it's known but despite all the fixes i still get:
>=20
>  drivers/built-in.o: In function `ne_drv_resume':
>  ne.c:(.text+0x146ba4): undefined reference to `NS8390_init'
>  drivers/built-in.o: In function `ne_block_output':
>  ne.c:(.text+0x146e00): undefined reference to `NS8390_init'

This should do the trick. I can't test it currently as that configurati=
on
now fails to build with mm errors in current git head..

mm/hugetlb.c: In function =E2=80=98hugetlb_acct_memory=E2=80=99: mm/hug=
etlb.c:1507:
error: implicit declaration of function =E2=80=98cpuset_mems_nr=E2=80=99

8390: Fix various compile errors

=46rom: Alan Cox <alan@redhat.com>

Some of the original patches got lost along the way, so sort out the
remaining stuff
---

 drivers/net/Makefile |    2 +-
 drivers/net/ne.c     |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)


diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7629c90..f66b79b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -111,7 +111,7 @@ obj-$(CONFIG_EL2) +=3D 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) +=3D ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) +=3D ne2.o 8390p.o
 obj-$(CONFIG_HPLAN) +=3D hp.o 8390p.o
-obj-$(CONFIG_HPLAN_PLUS) +=3D hp-plus.o 8390p.o
+obj-$(CONFIG_HPLAN_PLUS) +=3D hp-plus.o 8390.o
 obj-$(CONFIG_ULTRA) +=3D smc-ultra.o 8390.o
 obj-$(CONFIG_ULTRAMCA) +=3D smc-mca.o 8390.o
 obj-$(CONFIG_ULTRA32) +=3D smc-ultra32.o 8390.o
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 2fec612..4a8a4b1 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_device *dev,=
 unsigned long ioaddr)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller =3D eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
=20
 	ret =3D register_netdev(dev);
 	if (ret)
@@ -794,7 +794,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name)=
;
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev,1);
 			break;
 		}
=20
@@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform_device *pd=
ev)
=20
 	if (netif_running(dev)) {
 		ne_reset_8390(dev);
-		NS8390_init(dev, 1);
+		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
 	}
 	return 0;
