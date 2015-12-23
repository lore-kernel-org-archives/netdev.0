From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next v2 4/5] sfc: Downgrade EPERM messages from MCDI to
 debug
Date: Wed, 23 Dec 2015 08:57:51 +0000
Message-ID: <567A620F.7020205@solarflare.com>
References: <567A6170.6010104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:41513 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964977AbbLWI6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 03:58:03 -0500
In-Reply-To: <567A6170.6010104@solarflare.com>
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
index d6b8a77..d28e7dd 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1082,9 +1082,10 @@ void efx_mcdi_display_error(struct efx_nic *efx,=
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
