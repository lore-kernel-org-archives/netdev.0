From: "Koteshwar Rao, Satha" <Satha.Rao@cavium.com>
Subject: RE: [RFC PATCH 3/7] Enable pause frame support
Date: Mon, 26 Dec 2016 14:21:57 +0000
Message-ID: <DM5PR07MB28423DB384D388B4B9F9C6FB8D960@DM5PR07MB2842.namprd07.prod.outlook.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>,
 <1482310011-1862-4-git-send-email-satha.rao@caviumnetworks.com>
 <DM5PR07MB2889471E0668C95BD2A266709E930@DM5PR07MB2889.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "rric@kernel.org" <rric@kernel.org>, "Chickles,
 Derek" <Derek.Chickles@cavium.com>, "Daney, David" <David.Daney@cavium.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Vatsavayi,
 Raghu" <Raghu.Vatsavayi@cavium.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "Romanov, Philip" <Philip.Romanov@cavium.com>
To: "Goutham, Sunil" <Sunil.Goutham@cavium.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <DM5PR07MB2889471E0668C95BD2A266709E930@DM5PR07MB2889.namprd07.prod.outlook.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Thanks Sunil, will fix this in next version

Thanks,
Satha

From: Goutham, Sunil =

Sent: Wednesday, December 21, 2016 1:20 AM
To: Koteshwar Rao, Satha; linux-kernel@vger.kernel.org
Cc: rric@kernel.org; davem@davemloft.net; Daney, David; Vatsavayi, Raghu; C=
hickles, Derek; Romanov, Philip; netdev@vger.kernel.org; linux-arm-kernel@l=
ists.infradead.org
Subject: Re: [RFC PATCH 3/7] Enable pause frame support

>>+#define=A0 BGX_SMUX_CBFC_CTL=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0x20218

These macros are already defined.

if you check 'net-next ' branch pause frame support has already been
added. You should send patch on top it if you have further changes
to the existing.

Thanks,
Sunil.

________________________________________
From: Koteshwar Rao, Satha
Sent: Wednesday, December 21, 2016 2:16 PM
To: linux-kernel@vger.kernel.org
Cc: Goutham, Sunil; rric@kernel.org; davem@davemloft.net; Daney, David; Vat=
savayi, Raghu; Chickles, Derek; Koteshwar Rao, Satha; Romanov, Philip; netd=
ev@vger.kernel.org; linux-arm-kernel@lists.infradead.org
Subject: [RFC PATCH 3/7] Enable pause frame support =

=A0
---
=A0drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 25 +++++++++++++++++=
++++++
=A0drivers/net/ethernet/cavium/thunder/thunder_bgx.h |=A0 7 +++++++
=A02 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/ne=
t/ethernet/cavium/thunder/thunder_bgx.c
index 050e21f..92d7e04 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -121,6 +121,31 @@ static int bgx_poll_reg(struct bgx *bgx, u8 lmac, u64 =
reg, u64 mask, bool zero)
=A0=A0=A0=A0=A0=A0=A0=A0 return 1;
=A0}
=A0
+void enable_pause_frames(int node, int bgx_idx, int lmac)
+{
+=A0=A0=A0=A0=A0=A0 u64 reg_value =3D 0;
+=A0=A0=A0=A0=A0=A0 struct bgx *bgx =3D bgx_vnic[(node * MAX_BGX_PER_NODE) =
+ bgx_idx];
+
+=A0=A0=A0=A0=A0=A0 reg_value =3D=A0 bgx_reg_read(bgx, lmac, BGX_SMUX_TX_CT=
L);
+=A0=A0=A0=A0=A0=A0 /* Enable BGX()_SMU()_TX_CTL */
+=A0=A0=A0=A0=A0=A0 if (!(reg_value & L2P_BP_CONV))
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bgx_reg_write(bgx, lmac, BGX_SM=
UX_TX_CTL,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 (reg_value | (L2P_BP_CONV)));
+
+=A0=A0=A0=A0=A0=A0 reg_value =3D=A0 bgx_reg_read(bgx, lmac, BGX_SMUX_HG2_C=
TL);
+=A0=A0=A0=A0=A0=A0 /* Clear if BGX()_SMU()_HG2_CONTROL[HG2TX_EN] is set */
+=A0=A0=A0=A0=A0=A0 if (reg_value & SMUX_HG2_CTL_HG2TX_EN)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bgx_reg_write(bgx, lmac, BGX_SM=
UX_HG2_CTL,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 (reg_value & (~SMUX_HG2_CTL_HG2TX_EN)));
+
+=A0=A0=A0=A0=A0=A0 reg_value =3D=A0 bgx_reg_read(bgx, lmac, BGX_SMUX_CBFC_=
CTL);
+=A0=A0=A0=A0=A0=A0 /* Clear if BGX()_SMU()_CBFC_CTL[TX_EN] is set */
+=A0=A0=A0=A0=A0=A0 if (reg_value & CBFC_CTL_TX_EN)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bgx_reg_write(bgx, lmac, BGX_SM=
UX_CBFC_CTL,
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 (reg_value & (~CBFC_CTL_TX_EN)));
+}
+EXPORT_SYMBOL(enable_pause_frames);
+
=A0/* Return number of BGX present in HW */
=A0unsigned bgx_get_map(int node)
=A0{
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/ne=
t/ethernet/cavium/thunder/thunder_bgx.h
index 01cc7c8..5b57bd1 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -131,6 +131,11 @@
=A0#define BGX_SMUX_TX_CTL=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
0x20178
=A0#define=A0 SMU_TX_CTL_DIC_EN=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 BIT_ULL(0)
=A0#define=A0 SMU_TX_CTL_UNI_EN=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 BIT_ULL(1)
+#define=A0 L2P_BP_CONV=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 BIT_ULL(7)
+#define=A0 BGX_SMUX_CBFC_CTL=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0x20218
+#define=A0 CBFC_CTL_TX_EN=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 BIT_ULL(1)
+#define=A0 BGX_SMUX_HG2_CTL=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0x20210
+#define SMUX_HG2_CTL_HG2TX_EN=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 BIT_ULL(18)
=A0#define=A0 SMU_TX_CTL_LNK_STATUS=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 (3ull << 4)
=A0#define BGX_SMUX_TX_THRESH=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 0x20180
=A0#define BGX_SMUX_CTL=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 0x20200
@@ -212,6 +217,8 @@ void bgx_lmac_internal_loopback(int node, int bgx_idx,
=A0
=A0u64 bgx_get_rx_stats(int node, int bgx_idx, int lmac, int idx);
=A0u64 bgx_get_tx_stats(int node, int bgx_idx, int lmac, int idx);
+void enable_pause_frames(int node, int bgx_idx, int lmac);
+
=A0#define BGX_RX_STATS_COUNT 11
=A0#define BGX_TX_STATS_COUNT 18
=A0
-- =

1.8.3.1
