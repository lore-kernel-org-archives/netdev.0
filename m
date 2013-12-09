From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: [PATCH 04/10] net: stmmac: sunxi platfrom extensions for GMAC
 in Allwinner A20 SoC's
Date: Mon, 9 Dec 2013 11:21:22 +0000
Message-ID: <52A5A7B2.4000509@st.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Rob Herring <rob.herring@calxeda.com>,
 linux-sunxi@googlegroups.com, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 Maxime Ripard <maxime.ripard@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1386350983-13281-5-git-send-email-wens@csie.org>
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

On 06/12/13 17:29, Chen-Yu Tsai wrote:
> +static int sun7i_gmac_init(struct platform_device *pdev)
> +{
> +	struct resource *res;
> +	struct device *dev = &pdev->dev;
> +	void __iomem *addr = NULL;
> +	struct plat_stmmacenet_data *plat_dat = NULL;
> +	u32 priv_clk_reg;
> +
> +	plat_dat = dev_get_platdata(&pdev->dev);
> +	if (!plat_dat)
> +		return -EINVAL;
dev_get_platdata will return NULL for DT, So this function will fail all
the time.

How is it supposed to work?
Am I missing some thing?

--srini
> +
> +	/* Get GMAC clock register in CCU */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	addr = devm_ioremap_resource(dev, res);
> +	if (IS_ERR(addr))
