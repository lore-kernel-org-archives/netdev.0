From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] SuperH IrDA: correct Baud rate error correction
Date: Fri, 19 Nov 2010 01:24:02 +0100
Message-ID: <20101119012402.43e9aa61@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kuninori Morimoto <morimoto.kuninori@renesas.com>,
	irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:35073 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758097Ab0KSA2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 19:28:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks to me as if the second value of rate_err_array is intended
to be a decimal 625. However, with a leading 0 it becomes an octal
constant, and as such evaluates to a decimal 405.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 drivers/net/irda/sh_sir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 00b38bc..52a7c86 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -258,7 +258,7 @@ static int sh_sir_set_baudrate(struct sh_sir_self *self, u32 baudrate)
 
 	/* Baud Rate Error Correction x 10000 */
 	u32 rate_err_array[] = {
-		0000, 0625, 1250, 1875,
+		   0,  625, 1250, 1875,
 		2500, 3125, 3750, 4375,
 		5000, 5625, 6250, 6875,
 		7500, 8125, 8750, 9375,
-- 
1.7.2.2
