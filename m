From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH] net: stmmac: remove unused duplicate property snps,axi_all
Date: Fri, 30 Dec 2016 13:56:46 +0100
Message-ID: <1483102609-21926-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklass@axis.com>,
        Eric Engestrom <eric@engestrom.ch>,
        Gabriel Fernandez <gabriel.fernandez@linaro.org>,
        Joachim Eastwood <manabian@gmail.com>,
        Vincent Palatin <vpalatin@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

For core revision 3.x Address-Aligned Beats is available in two registers.
The DT property snps,aal was created for AAL in the DMA bus register,
which is a read/write bit.
The DT property snps,axi_all was created for AXI_AAL in the AXI bus mode
register, which is a read only bit that reflects the value of AAL in the
DMA bus register.

Since the value of snps,axi_all is never used in the driver,
and since the property was created for a bit that is read only,
it should be safe to remove the property.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      | 1 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 include/linux/stmmac.h                                | 1 -
 3 files changed, 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 128da752fec9..c3d2fd480a1b 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -65,7 +65,6 @@ Optional properties:
 	- snps,wr_osr_lmt: max write outstanding req. limit
 	- snps,rd_osr_lmt: max read outstanding req. limit
 	- snps,kbbe: do not cross 1KiB boundary.
-	- snps,axi_all: align address
 	- snps,blen: this is a vector of supported burst length.
 	- snps,fb: fixed-burst
 	- snps,mb: mixed-burst
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 082cd48db6a7..60ba8993c650 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -121,7 +121,6 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
 	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm");
 	axi->axi_kbbe = of_property_read_bool(np, "snps,axi_kbbe");
-	axi->axi_axi_all = of_property_read_bool(np, "snps,axi_all");
 	axi->axi_fb = of_property_read_bool(np, "snps,axi_fb");
 	axi->axi_mb = of_property_read_bool(np, "snps,axi_mb");
 	axi->axi_rb =  of_property_read_bool(np, "snps,axi_rb");
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 266dab9ad782..889e0e9a3f1c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -103,7 +103,6 @@ struct stmmac_axi {
 	u32 axi_wr_osr_lmt;
 	u32 axi_rd_osr_lmt;
 	bool axi_kbbe;
-	bool axi_axi_all;
 	u32 axi_blen[AXI_BLEN];
 	bool axi_fb;
 	bool axi_mb;
-- 
2.1.4
