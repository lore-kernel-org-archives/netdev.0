From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix vector traveling while looking for an
 empty entry
Date: Tue, 27 Mar 2012 09:08:55 +0200
Message-ID: <1332832135-22054-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2111 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115Ab2C0HJS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 03:09:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes the bug that may prevent from mac to be configured,
while there is an empty slot for it.

Reported-by: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/n=
et/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 3f52fad..5135733 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -3847,7 +3847,7 @@ static bool bnx2x_credit_pool_get_entry(
 			continue;
=20
 		/* If we've got here we are going to find a free entry */
-		for (idx =3D vec * BNX2X_POOL_VEC_SIZE, i =3D 0;
+		for (idx =3D vec * BIT_VEC64_ELEM_SZ, i =3D 0;
 		      i < BIT_VEC64_ELEM_SZ; idx++, i++)
=20
 			if (BIT_VEC64_TEST_BIT(o->pool_mirror, idx)) {
--=20
1.7.7.2
