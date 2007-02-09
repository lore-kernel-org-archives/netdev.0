From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Fri, 9 Feb 2007 13:07:30 +0100
Message-ID: <20070209120730.GA11911@melchior.yamamaya.is-a-geek.org>
References: <45C6BCE5.90103@shaw.ca> <20070204213603.a5bce839.akpm@linux-foundation.org> <45C6C531.20508@shaw.ca> <20070204221741.63152cbe.akpm@linux-foundation.org> <523e55a00702081326j43de05e3hdd8cf35e946eae9@mail.gmail.com> <45CBE30D.5030006@nvidia.com> <20070209115821.GD10330@melchior.yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ayaz Abdulla <aabdulla@nvidia.com>,
	David Ford <firefighterblu3@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robert Hancock <hancockr@shaw.ca>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:3897 "EHLO yumi.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946401AbXBIMHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 07:07:32 -0500
Content-Disposition: inline
In-Reply-To: <20070209115821.GD10330@melchior.yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tobias Diedrich wrote:
> Ayaz Abdulla wrote:
> > For all those who are having issues, please try out the attached pa=
tch.
>=20
> Will try.

Does not apply cleanly against 2.6.20, is this one fixed up right?
--- linux-2.6.20/drivers/net/forcedeth.c.orig	2007-02-09 13:02:02.00000=
0000 +0100
+++ linux-2.6.20/drivers/net/forcedeth.c.new	2007-02-09 13:03:45.000000=
000 +0100
@@ -2603,10 +2603,16 @@
 	struct fe_priv *np =3D netdev_priv(dev);
 	u8 __iomem *base =3D get_hwbase(dev);
 	unsigned long flags;
+	u32 retcode;
=20
-	pkts =3D nv_rx_process(dev, limit);
+	if (np->desc_ver =3D=3D DESC_VER_1 || np->desc_ver =3D=3D DESC_VER_2)=
 {
+		pkts =3D nv_rx_process(dev, limit);
+		retcode =3D nv_alloc_rx(dev);
+	} else {
+		retcode =3D nv_alloc_rx_optimized(dev);
+	}
=20
-	if (nv_alloc_rx(dev)) {
+	if (retcode) {
 		spin_lock_irqsave(&np->lock, flags);
 		if (!np->in_shutdown)
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
