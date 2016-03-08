From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 05/11] marvell.c: fix strict alias warnings
Date: Mon,  7 Mar 2016 19:34:56 -0800
Message-ID: <1457408102-46662-6-git-send-email-ddecotig@gmail.com>
References: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36588 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbcCHDfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:35:18 -0500
Received: by mail-pf0-f196.google.com with SMTP id q129so347496pfb.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 19:35:18 -0800 (PST)
In-Reply-To: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Addresses the following warnings:
  marvell.c:426:2: error: dereferencing type-punned pointer will break =
strict-aliasing rules [-Werror=3Dstrict-aliasing]
  marvell.c:427:2: error: dereferencing type-punned pointer will break =
strict-aliasing rules [-Werror=3Dstrict-aliasing]
  marvell.c:428:2: error: dereferencing type-punned pointer will break =
strict-aliasing rules [-Werror=3Dstrict-aliasing]

Note: code appears endian-dependent, not fixed by this commit.


Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: David Decotigny <decot@googlers.com>
---
 marvell.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/marvell.c b/marvell.c
index e583c82..af21188 100644
--- a/marvell.c
+++ b/marvell.c
@@ -381,7 +381,8 @@ static void dump_prefetch(const char *name, const v=
oid *r)
=20
 int sky2_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *=
regs)
 {
-	const u32 *r =3D (const u32 *) regs->data;
+	const u16 *r16 =3D (const u16 *) regs->data;
+	const u32 *r32 =3D (const u32 *) regs->data;
 	int dual;
=20
 	dump_pci(regs->data + 0x1c00);
@@ -390,15 +391,15 @@ int sky2_dump_regs(struct ethtool_drvinfo *info, =
struct ethtool_regs *regs)
=20
 	printf("\nBus Management Unit\n");
 	printf("-------------------\n");
-	printf("CSR Receive Queue 1              0x%08X\n", r[24]);
-	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
-	printf("CSR Async Queue 1                0x%08X\n", r[27]);
+	printf("CSR Receive Queue 1              0x%08X\n", r32[24]);
+	printf("CSR Sync Queue 1                 0x%08X\n", r32[26]);
+	printf("CSR Async Queue 1                0x%08X\n", r32[27]);
=20
 	dual =3D (regs->data[0x11e] & 2) !=3D 0;
 	if (dual) {
-		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
-		printf("CSR Async Queue 2                0x%08X\n", r[29]);
-		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
+		printf("CSR Receive Queue 2              0x%08X\n", r32[25]);
+		printf("CSR Async Queue 2                0x%08X\n", r32[29]);
+		printf("CSR Sync Queue 2                 0x%08X\n", r32[28]);
 	}
=20
 	dump_mac(regs->data);
@@ -423,9 +424,9 @@ int sky2_dump_regs(struct ethtool_drvinfo *info, st=
ruct ethtool_regs *regs)
 	dump_timer("TX status", regs->data + 0xec0);
 	dump_timer("ISR", regs->data + 0xed0);
=20
-	printf("\nGMAC control             0x%04X\n", *(u32 *)(regs->data + 0=
xf00));
-	printf("GPHY control             0x%04X\n", *(u32 *)(regs->data + 0xf=
04));
-	printf("LINK control             0x%02hX\n", *(u16 *)(regs->data + 0x=
f10));
+	printf("\nGMAC control             0x%04X\n", r32[0xf00 >> 2]);
+	printf("GPHY control             0x%04X\n", r32[0xf04 >> 2]);
+	printf("LINK control             0x%02hX\n", r16[0xf10 >> 1]);
=20
 	dump_gmac("GMAC 1", regs->data + 0x2800);
 	dump_gmac_fifo("Rx GMAC 1", regs->data + 0xc40);
--=20
2.7.0.rc3.207.g0ac5344
