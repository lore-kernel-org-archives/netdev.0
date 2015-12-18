From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 4/5] sfc: Downgrade EPERM messages from MCDI to debug
Date: Fri, 18 Dec 2015 17:09:57 +0000
Message-ID: <56743DE5.80609@solarflare.com>
References: <56743D6A.5020605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Tomas Pilar <tpilar@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:36649 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933050AbbLRRKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 12:10:14 -0500
In-Reply-To: <56743D6A.5020605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Tom=C3=A1=C5=A1 Pila=C5=99 <tpilar@solarflare.com>

When running in an unprivileged function we expect some MC commands
to fail with permission errors. To avoid log spew downgrade these to
debug only.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc=
/mcdi.c
index ab68ff6..7df183a 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1084,9 +1084,10 @@ void efx_mcdi_display_error(struct efx_nic *efx,=
 unsigned cmd,
 		code =3D MCDI_DWORD(outbuf, ERR_CODE);
 	if (outlen >=3D MC_CMD_ERR_ARG_OFST + 4)
 		err_arg =3D MCDI_DWORD(outbuf, ERR_ARG);
-	netif_err(efx, hw, efx->net_dev,
-		  "MC command 0x%x inlen %d failed rc=3D%d (raw=3D%d) arg=3D%d\n",
-		  cmd, (int)inlen, rc, code, err_arg);
+	netif_printk(efx, hw, rc =3D=3D -EPERM ? KERN_DEBUG : KERN_ERR,
+		     efx->net_dev,
+		     "MC command 0x%x inlen %zu failed rc=3D%d (raw=3D%d) arg=3D%d\n=
",
+		     cmd, inlen, rc, code, err_arg);
 }
=20
 /* Switch to polled MCDI completions.  This can be called in various
--=20
2.4.3
