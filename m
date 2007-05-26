From: Andreas Schwab <schwab@suse.de>
Subject: [PATCH] Avoid switch on long long in s2io driver
Date: Sat, 26 May 2007 10:58:15 +0200
Message-ID: <jebqg8kllk.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:48432 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753841AbXEZI6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 04:58:17 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id A791B124AB
	for <netdev@vger.kernel.org>; Sat, 26 May 2007 10:58:16 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A switch on long long causes gcc to generate a reference to __ucmpdi2 o=
n
ppc32.  Avoid that by casting to int, since the value is only a small
integer anyway.

Signed-off-by: Andreas Schwab <schwab@suse.de>

---
 drivers/net/s2io.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/s2io.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.22-rc1.orig/drivers/net/s2io.c	2007-05-13 11:03:28.000000=
000 +0200
+++ linux-2.6.22-rc1/drivers/net/s2io.c	2007-05-13 12:52:49.000000000 +=
0200
@@ -2898,7 +2898,7 @@ static void tx_intr_handler(struct fifo_
=20
 			/* update t_code statistics */
 			err >>=3D 48;
-			switch(err) {
+			switch((int)err) {
 				case 2:
 					nic->mac_control.stats_info->sw_stat.
 							tx_buf_abort_cnt++;
@@ -6825,7 +6825,7 @@ static int rx_osm_handler(struct ring_in
 			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
 		}
 		err >>=3D 48;
-		switch(err) {
+		switch((int)err) {
 			case 1:
 				sp->mac_control.stats_info->sw_stat.
 				rx_parity_err_cnt++;

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
