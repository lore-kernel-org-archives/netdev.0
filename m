From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/atm/clip.c: fix PROC_FS=n compile
Date: Sat, 8 Jul 2006 22:20:01 +0200
Message-ID: <20060708202000.GC5020@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.n
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:55047 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1030322AbWGHUUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:20:01 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following compile error with CONFIG_PROC_FS=3Dn by=
=20
reverting commit dcdb02752ff13a64433c36f2937a58d93ae7a19e:

<--  snip  -->

=2E..
  CC      net/atm/clip.o
net/atm/clip.c: In function =E2=80=98atm_clip_init=E2=80=99:
net/atm/clip.c:975: error: =E2=80=98atm_proc_root=E2=80=99 undeclared (=
first use in this function)
net/atm/clip.c:975: error: (Each undeclared identifier is reported only=
 once
net/atm/clip.c:975: error: for each function it appears in.)
net/atm/clip.c:977: error: =E2=80=98arp_seq_fops=E2=80=99 undeclared (f=
irst use in this function)
make[2]: *** [net/atm/clip.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/atm/clip.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

--- linux-2.6.17-mm6-full/net/atm/clip.c.old	2006-07-08 13:58:07.000000=
000 +0200
+++ linux-2.6.17-mm6-full/net/atm/clip.c	2006-07-08 13:55:48.000000000 =
+0200
@@ -962,7 +962,6 @@
=20
 static int __init atm_clip_init(void)
 {
-	struct proc_dir_entry *p;
 	neigh_table_init_no_netlink(&clip_tbl);
=20
 	clip_tbl_hook =3D &clip_tbl;
@@ -972,9 +971,15 @@
=20
 	setup_timer(&idle_timer, idle_timer_check, 0);
=20
-	p =3D create_proc_entry("arp", S_IRUGO, atm_proc_root);
-	if (p)
-		p->proc_fops =3D &arp_seq_fops;
+#ifdef CONFIG_PROC_FS
+	{
+		struct proc_dir_entry *p;
+
+		p =3D create_proc_entry("arp", S_IRUGO, atm_proc_root);
+		if (p)
+			p->proc_fops =3D &arp_seq_fops;
+	}
+#endif
=20
 	return 0;
 }

