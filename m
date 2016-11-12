From: Marion & Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Spurious code in commit 1bf40ada6290 ("amd-xgbe: Add support for
 clause 37 auto-negotiation"
Date: Sat, 12 Nov 2016 15:34:27 +0100
Message-ID: <80c6a7b3-4a03-e087-3638-7048adebbda8@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kernel Janitors <kernel-janitors@vger.kernel.org>
To: thomas.lendacky@amd.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

in commit 1bf40ada6290 ("amd-xgbe: Add support for clause 37 
auto-negotiation"), we can find:

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h 
b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 695e982..8bcf4ef 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
    [...]
    #define XGBE_AN_CL37_PCS_MODE_MASK    0x06
    #define XGBE_AN_CL37_PCS_MODE_BASEX    0x00
    #define XGBE_AN_CL37_PCS_MODE_SGMII    0x04
    #define XGBE_AN_CL37_TX_CONFIG_MASK    0x08
    [...]

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c 
b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index d5bfbe4..723eb90 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
    [...]
    /* Set up the Control register */
    reg = XMDIO_READ(pdata, MDIO_MMD_VEND2, MDIO_VEND2_AN_CTRL);
    reg &= XGBE_AN_CL37_TX_CONFIG_MASK;
    reg &= XGBE_AN_CL37_PCS_MODE_MASK;
    [...]

the "reg &=" statements look spurious. The 2 constants being 0x06 and 
0x08, the current code is equivalent to "reg = 0"

It is likely that "reg |=" (or "reg &= ~") was expected here.

Best regards,
CJ
