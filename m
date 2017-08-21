From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 0/5] ARM: dts: rcar-gen2: Convert to new CPG/MSSR
 bindings
Date: Mon, 21 Aug 2017 11:02:47 +0200
Message-ID: <20170821090247.GE14174@verge.net.au>
References: <1503047498-29078-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>,
        linux-renesas-soc@vger.kernel.org, linux-clk@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503047498-29078-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2017 at 11:11:33AM +0200, Geert Uytterhoeven wrote:
> 	Hi Simon, Magnus,
> 
> Currently Renesas R-Car Gen2 SoCs use the common clk-rcar-gen2,
> clk-mstp, and clk-div6 drivers, which depend on most clocks being
> described in DT.  Especially the module (MSTP) clocks are cumbersome and
> error prone, due to 3 arrays (clocks, clock-indices, and
> clock-output-names) to be kept in sync. In addition, the clk-mstp driver
> cannot be extended easily to also support module resets, which are
> provided by the same hardware module.
> 
> Hence when developing support for R-Car Gen3 SoCs, another approach was
> chosen, which led to the CPG/MSSR driver core, and SoC-specific
> subdrivers (initially for R-Car Gen3, but later also for RZ/G1).
> 
> This series converts the various R-Car Gen2 DTSes to migrate to the new
> CPG/MSSR drivers that were added in v4.13-rc1.
> 
> Note that module reset descriptions will be added later.
> 
> Changes compared to v1:
>   - Rebased.
> 
> Dependencies:
>   - renesas-devel-20170818-v4.13-rc5.
> 
> Known issues:
>   - The CPG/MSSR driver is initialized later than the old clk-rcar-gen2
>     driver, causing changes of initialization order for other drivers.
> 
>     Currently the PHY subsystem does not support probe deferral
> 
> 	+irq: no irq domain found for /interrupt-controller@e61c0000 !
> 
> 	-Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=182)
> 	+Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=-1)
> 
>     leading to the Ethernet PHY falling back to polling instead of using an
>     interrupt.  This can be remedied by "of_mdio: Fix broken PHY IRQ in
>     case of probe deferral" (https://patchwork.kernel.org/patch/9734175/),
>     which is still pending approval.
> 
>     Fortunately the impact of this is limited to a small delay in the
>     detection of cable (un)plugging.
>     Note that when using the PHY interrupt, cable unplugging is reported
>     instantaneous, but plugging takes ca. 1.5-1.8 seconds.  Hence when
>     using polling with the standard interval of 1 second, the link comes up
>     in about the same time.
> 
> For your convenience, this series is also available in the
> topic/rcar2-cpg-mssr-dt-v2 branch of my renesas-drivers git repository at
> git://git.kernel.org/pub/scm/linux/kernel/git/geert/renesas-drivers.git.
> 
> This has been tested on r8a7790/lager, r8a7791/koelsch, r8a7792/blanche,
> r8a7793/gose, and r8a7794/alt.  /sys/kernel/debug/clk/clk_summary has
> been compared before and after the conversion.
> 
> Thanks for applying!

Thanks, applied for v4.15.
