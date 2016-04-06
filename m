From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v2] ARC: axs10x - add Ethernet PHY description in .dts
Date: Wed, 6 Apr 2016 14:42:13 +0530
Message-ID: <5704D2ED.4060507@synopsys.com>
References: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
 Phil Reid <preid@electromag.com.au>, "David S. Miller" <davem@davemloft.net>,
 Gabriel Fernandez <gabriel.fernandez@linaro.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
 <linux-snps-arc@lists.infradead.org>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <1458207712-29435-1-git-send-email-abrodkin@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

On Thursday 17 March 2016 03:11 PM, Alexey Brodkin wrote:
> Following commit broke DW GMAC functionality on AXS10x boards:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e34d65696d2ef13dc32f2a162556c86c461ed763
> 
> That's what happens on eth0 up:
> --------------------------->8------------------------
> libphy: PHY stmmac-0:ffffffff not found
> eth0: Could not attach to PHY
> stmmac_open: Cannot attach to PHY (error: -19)
> --------------------------->8------------------------
> 
> Simplest solution is to add PHY description in board's .dts.
> And so we do here.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
> Cc: Rob Herring <robh@kernel.org>
> Cc: Phil Reid <preid@electromag.com.au>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: stable@vger.kernel.org # 4.5.x
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
> 
> Changes v1 -> v2:
>  * PHY node name changed to match real PHY number being used (Sergei)
> 
>  arch/arc/boot/dts/axs10x_mb.dtsi | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/arch/arc/boot/dts/axs10x_mb.dtsi b/arch/arc/boot/dts/axs10x_mb.dtsi
> index 44a578c..ab5d570 100644
> --- a/arch/arc/boot/dts/axs10x_mb.dtsi
> +++ b/arch/arc/boot/dts/axs10x_mb.dtsi
> @@ -47,6 +47,14 @@
>  			clocks = <&apbclk>;
>  			clock-names = "stmmaceth";
>  			max-speed = <100>;
> +			mdio0 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				compatible = "snps,dwmac-mdio";
> +				phy1: ethernet-phy@1 {
> +					reg = <1>;
> +				};
> +			};
>  		};
>  
>  		ehci@0x40000 {


So above DT fix for ARC went into 4.6-rc1 and ethernet was still broken on axs103
board.

---------->8-------------
libphy: PHY stmmac-0:ffffffff not found
eth0: Could not attach to PHY
stmmac_open: Cannot attach to PHY (error: -19)
---------->8-------------

On 4.6-rc2 if I revert the DT change, ethernet works again.

@Giuseppe, @Phil, @Gabriel, I see you have made changes in that area. I presume
that above revert is the right/sufficient thing or do we need to do something else
as well.

TIA,
-Vineet
