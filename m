From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5BPATCH=20=28net=2Egit=29=201/3=5D=20stmmac=3A=20fix=20TX=20normal=20DESC?=
Date: Fri, 1 Apr 2016 09:07:14 +0200
Message-ID: <1459494436-27386-2-git-send-email-peppe.cavallaro@st.com>
References: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<rhgadsdon@gmail.com>, <linux-kernel@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixs a regression raised when test on chips that use
the normal descriptor layout. In fact, no len bits were set for
the TDES1 and no OWN bit inside the TDES0.

Signed-off-by: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Tested-by: Andreas F=C3=A4rber <afaerber@suse.de>
Cc: Fabrice Gasnier <fabrice.gasnier@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c |   16 ++++++++-------=
-
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/=
net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..011386f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -199,11 +199,6 @@ static void ndesc_prepare_tx_desc(struct dma_desc =
*p, int is_fs, int len,
 {
 	unsigned int tdes1 =3D p->des1;
=20
-	if (mode =3D=3D STMMAC_CHAIN_MODE)
-		norm_set_tx_desc_len_on_chain(p, len);
-	else
-		norm_set_tx_desc_len_on_ring(p, len);
-
 	if (is_fs)
 		tdes1 |=3D TDES1_FIRST_SEGMENT;
 	else
@@ -217,10 +212,15 @@ static void ndesc_prepare_tx_desc(struct dma_desc=
 *p, int is_fs, int len,
 	if (ls)
 		tdes1 |=3D TDES1_LAST_SEGMENT;
=20
-	if (tx_own)
-		tdes1 |=3D TDES0_OWN;
-
 	p->des1 =3D tdes1;
+
+	if (mode =3D=3D STMMAC_CHAIN_MODE)
+		norm_set_tx_desc_len_on_chain(p, len);
+	else
+		norm_set_tx_desc_len_on_ring(p, len);
+
+	if (tx_own)
+		p->des0 |=3D TDES0_OWN;
 }
=20
 static void ndesc_set_tx_ic(struct dma_desc *p)
--=20
1.7.4.4
