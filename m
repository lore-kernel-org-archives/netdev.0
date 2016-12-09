From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: stmmac DT property snps,axi_all
Date: Fri, 9 Dec 2016 10:53:52 +0100
Message-ID: <e0362693-4ae9-b3d6-3955-c72df7a1b0c0@axis.com>
References: <51f8249e-bdb9-e3a7-5d82-7ac869316f0e@axis.com>
 <120aca00-02a8-3d88-7aad-a21d239aafb2@st.com>
 <dc145c32-cb67-4bcb-e8b7-059387d5a0ac@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:36251 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752524AbcLIJx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 04:53:56 -0500
In-Reply-To: <dc145c32-cb67-4bcb-e8b7-059387d5a0ac@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2016 10:20 AM, Niklas Cassel wrote:
> On 12/08/2016 02:36 PM, Alexandre Torgue wrote:
>> Hi Niklas,
>>
>> On 12/05/2016 05:18 PM, Niklas Cassel wrote:
>>> Hello Giuseppe
>>>
>>>
>>> I'm trying to figure out what snps,axi_all is supposed to represent.
>>>
>>> It appears that the value is saved, but never used in the code.
>>>
>>> Looking at the register specification, I'm guessing that it represents
>>> Address-Aligned Beats, but there is already the property snps,aal
>>> for that.
>> IMO, it is not useful. Indeed AXI_AAL is a read only bit (in AXI bus mode register) and reflects the aal bit in DMA bus register.
>> As you know we use "snps,aal" to set aal bit in DMA bus register.
>> So "snps,axi_all" entry seems useless. Let's see with Peppe.
> Ok, I see. GMAC and GMAC4 is different here.
>
> For GMAC4 AAL only exists in DMA_SYS_BUS_MODE.
> It's not reflected anywhere else.
>
> The code is correct in the driver.
>
> If snps,axi_all is just created for a read-only register,
> and it is currently never used in the code,
> while we have snps,aal, which is correct and works,
> I guess it should be ok to remove snps,axi_all.
>
> I can cook up a patch.
>

Here we go :)

I will send it as a real patch once net-next reopens.


>From defc01cb7c22611b89d9cf1fcae72544092bd62c Mon Sep 17 00:00:00 2001
From: Niklas Cassel <niklas.cassel@axis.com>
Date: Fri, 9 Dec 2016 10:27:00 +0100
Subject: [PATCH net-next] net: stmmac: remove unused duplicate property
 snps,axi_all

For core revision 3.x Address-Aligned Beats is available in two registers.
The DT property snps,aal was created for AAL in the DMA bus register,
which is a read/write bit.
The DT property snps,axi_all was created for AXI_AAL in the AXI bus mode
register, which is a read only bit that reflects the value of AAL in the
DMA bus register.

Since the value of snps,axi_all is never used in the driver,
and since the property was created for a bit that is read only,
it should be safe to remove the property.

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
-    - snps,axi_all: align address
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
-    axi->axi_axi_all = of_property_read_bool(np, "snps,axi_all");
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
-    bool axi_axi_all;
     u32 axi_blen[AXI_BLEN];
     bool axi_fb;
     bool axi_mb;
-- 
2.1.4
