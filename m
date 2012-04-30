From: joseph daniel <josephdanielwalter@gmail.com>
Subject: [PATCH] net/nfc: Fix the compilation warning
Date: Mon, 30 Apr 2012 13:43:15 +0600
Message-ID: <1335771795-18961-1-git-send-email-josephdanielwalter@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joseph daniel <josephdanielwalter@gmail.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54414 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab2D3Hn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 03:43:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the nfc_llcp_general_bytes is defined in nfc/core.c as
    static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, size_=
t *gb_len).

as in nfc/nfc.h:
    static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, u8 *g=
b_len), as
    CONFIG_NFC_LLCP is not defined.

so we got some warnings,
net/nfc/core.c:207:2: warning: passing argument 2 of =E2=80=98nfc_llcp_=
general_bytes=E2=80=99 from incompatible pointer type [enabled by defau=
lt]
net/nfc/nfc.h:87:19: note: expected =E2=80=98u8 *=E2=80=99 but argument=
 is of type =E2=80=98size_t *=E2=80=99

Signed-off-by: joseph daniel <josephdanielwalter@gmail.com>
---
 net/nfc/nfc.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index ec8794c..549382c 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -84,7 +84,7 @@ static inline int nfc_llcp_set_remote_gb(struct nfc_d=
ev *dev,
 	return 0;
 }
=20
-static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, u8 *gb_l=
en)
+static inline u8 *nfc_llcp_general_bytes(struct nfc_dev *dev, size_t *=
gb_len)
 {
 	*gb_len =3D 0;
 	return NULL;
--=20
1.7.9.5
