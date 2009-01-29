From: Daniel =?iso-8859-1?q?Marjam=E4ki?= <danielm77@spray.se>
Subject: [PATCH] fix memory leak in drivers/net/netxen_nic_init.c
Date: Thu, 29 Jan 2009 19:55:56 +0100
Message-ID: <200901291955.56832.danielm77@spray.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch-smtp01.sth.basefarm.net ([80.76.149.212]:45800 "EHLO
	ch-smtp01.sth.basefarm.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751500AbZA2S4O convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 13:56:14 -0500
Received: from c83-255-10-24.bredband.comhem.se ([83.255.10.24]:12165 helo=sholahas.localnet)
	by ch-smtp01.sth.basefarm.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <danielm77@spray.se>)
	id 1LSc3f-00076w-5T
	for netdev@vger.kernel.org; Thu, 29 Jan 2009 19:56:12 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Marjam=E4ki <danielm77@spray.se>

=46or kernel bugzilla #12537:
http://bugzilla.kernel.org/show_bug.cgi?id=3D12537

=46ree memory.

Signed-off-by: Daniel Marjam=E4ki <danielm77@spray.se>
Reported-by: Daniel Marjam=E4ki <danielm77@spray.se>
---
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/=
netxen_nic_init.c
index ca7c8d8..ffd37be 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -947,8 +947,10 @@ int netxen_pinit_from_rom(struct netxen_adapter *a=
dapter, int verbose)
 	}
 	for (i =3D 0; i < n; i++) {
 		if (netxen_rom_fast_read(adapter, 8*i + 4*offset, &val) !=3D 0 ||
-		netxen_rom_fast_read(adapter, 8*i + 4*offset + 4, &addr) !=3D 0)
+		netxen_rom_fast_read(adapter, 8*i + 4*offset + 4, &addr) !=3D 0) {
+			kfree(buf);
 			return -EIO;
+		}

 		buf[i].addr =3D addr;
 		buf[i].data =3D val;




