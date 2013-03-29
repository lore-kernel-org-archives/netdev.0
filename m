From: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Subject: Re: [PATCH 2/4] ARM: kirkwood: add device node entries for the
 gigabit interfaces
Date: Fri, 29 Mar 2013 14:48:52 -0400
Message-ID: <20130329184852.GM13280@titan.lakedaemon.net>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org>
 <1364580879-4297-3-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: moinejf-GANU6spQydw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1364580879-4297-3-git-send-email-florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Mar 29, 2013 at 07:14:37PM +0100, Florian Fainelli wrote:
> This patch modifies kirkwood.dtsi to specify the various gigabit
> interfaces nodes available on kirkwood devices. They are disabled by
> default and should be enabled on a per-board basis. egiga0 and egiga1
> aliases are defined for convenience. The mdio node is also present and
> should be enabled on a per-board basis as well.
> 
> Signed-off-by: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
> ---
>  arch/arm/boot/dts/kirkwood.dtsi |   46 +++++++++++++++++++++++++++++++++++++++
>  arch/arm/mach-kirkwood/common.c |    4 ++--
>  2 files changed, 48 insertions(+), 2 deletions(-)
> 
...
> diff --git a/arch/arm/mach-kirkwood/common.c b/arch/arm/mach-kirkwood/common.c
> index 49792a0..a606f9f 100644
> --- a/arch/arm/mach-kirkwood/common.c
> +++ b/arch/arm/mach-kirkwood/common.c
> @@ -251,8 +251,8 @@ void __init kirkwood_clk_init(void)
>  	/* clkdev entries, mapping clks to devices */
>  	orion_clkdev_add(NULL, "orion_spi.0", runit);
>  	orion_clkdev_add(NULL, "orion_spi.1", runit);
> -	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".0", ge0);
> -	orion_clkdev_add(NULL, MV643XX_ETH_NAME ".1", ge1);
> +	orion_clkdev_add("0", MV643XX_ETH_NAME ".0", ge0);
> +	orion_clkdev_add("1", MV643XX_ETH_NAME ".1", ge1);

Your first patch is going to go through David's tree, and I'd like to
prevent any hard dependency between his tree and arm-soc.  Can this
change be pulled out and applied separately?  At first glance, it looks
like a fix to match sata and pcie.

thx,

Jason.
