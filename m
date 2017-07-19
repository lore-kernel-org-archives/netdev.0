From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/2] net: phy: at803x: Fix RGMII RX and TX clock delays
 setup
Date: Wed, 19 Jul 2017 14:24:10 -0500
Message-ID: <5ea9905f-e74a-4a43-dc5b-883ec9daf030@ti.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
 Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
 "David S. Miller" <davem@davemloft.net>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>, Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>, Florian Fainelli
 <f.fainelli@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Mans Rullgard
 <mans@mansr.com>, Martin Blumenstingl <martin.blumenstingl@gmail.com>,
 Fabio Estevam <fabio.estevam@nxp.com>,
 Zefir Kurtisi <zefir.kurtisi@neratec.com>,
 Timur Tabi <timur@codeaurora.org>, Daniel Mack <zonque@gmail.com>, Sekhar
 Nori <nsekhar@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
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

Hi

On 07/19/2017 10:31 AM, Marc Gonzalez wrote:
> The current code supports enabling RGMII RX and TX clock delays.
> The unstated assumption is that these settings are disabled by
> default at reset, which is not the case.
> 
> RX clock delay is enabled at reset. And TX clock delay "survives"
> across SW resets. Thus, if the bootloader enables TX clock delay,
> it will remain enabled at reset in Linux.
> 
> Provide disable functions to configure the RGMII clock delays
> exactly as specified in the fwspec.
> 
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> ---
>   drivers/net/phy/at803x.c | 32 ++++++++++++++++++++++++--------
>   1 file changed, 24 insertions(+), 8 deletions(-)
This patch breaks am335x-evm networking.

To restore it I've had to apply below diff:
diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 200d6ab..9578bdf 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -724,12 +724,12 @@
 
 &cpsw_emac0 {
        phy_id = <&davinci_mdio>, <0>;
-       phy-mode = "rgmii-txid";
+       phy-mode = "rgmii-id";
 };
 
 &cpsw_emac1 {
        phy_id = <&davinci_mdio>, <1>;
-       phy-mode = "rgmii-txid";
+       phy-mode = "rgmii-id";
 };
 
 &tscadc {

Sry, can't comment here to much - not E-PHY expert.

-- 
regards,
-grygorii
