From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 3/5] ARM: sun8i: dt: Add DT bindings
 documentation for Allwinner sun8i-emac
Date: Thu, 21 Jul 2016 09:55:19 +0200
Message-ID: <20160721075519.GC5993@lukather>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-4-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jy6Sn24JjFx/iggw"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBB4X7YG6AKGQEEWDSUHQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <1469001800-11615-4-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--jy6Sn24JjFx/iggw
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

Hi,

On Wed, Jul 20, 2016 at 10:03:18AM +0200, LABBE Corentin wrote:
> This patch adds documentation for Device-Tree bindings for the
> Allwinner sun8i-emac driver.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  .../bindings/net/allwinner,sun8i-emac.txt          | 65 ++++++++++++++++++++++
>  1 file changed, 65 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> new file mode 100644
> index 0000000..4bf4e53
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
> @@ -0,0 +1,65 @@
> +* Allwinner sun8i EMAC ethernet controller
> +
> +Required properties:
> +- compatible: "allwinner,sun8i-a83t-emac", "allwinner,sun8i-h3-emac",
> +		or "allwinner,sun50i-a64-emac"
> +- reg: address and length of the register sets for the device.
> +- reg-names: should be "emac" and "syscon", matching the register sets

Blindly mapping a register of some other device on the SoC doesn't
look very reasonable.

> +- interrupts: interrupt for the device
> +- clocks: A phandle to the reference clock for this device
> +- clock-names: should be "ahb"
> +- resets: A phandle to the reset control for this device
> +- reset-names: should be "ahb"
> +- phy-mode: See ethernet.txt
> +- phy or phy-handle: See ethernet.txt
> +- #address-cells: shall be 1
> +- #size-cells: shall be 0
> +
> +"allwinner,sun8i-h3-emac" also requires:
> +- clocks: an extra phandle to the reference clock for the EPHY
> +- clock-names: an extra "ephy" entry matching the clocks property
> +- resets: an extra phandle to the reset control for the EPHY
> +- resets-names: an extra "ephy" entry matching the resets property

Shouldn't that be attached to the phy itself?

> +See ethernet.txt in the same directory for generic bindings for ethernet
> +controllers.
> +
> +The device node referenced by "phy" or "phy-handle" should be a child node
> +of this node. See phy.txt for the generic PHY bindings.
> +
> +Optional properties:
> +- phy-supply: phandle to a regulator if the PHY needs one
> +- phy-io-supply: phandle to a regulator if the PHY needs a another one for I/O.
> +		 This is sometimes found with RGMII PHYs, which use a second
> +		 regulator for the lower I/O voltage.
> +- allwinner,tx-delay: The setting of the TX clock delay chain
> +- allwinner,rx-delay: The setting of the RX clock delay chain

In which unit? What is the default value?

> +
> +The TX/RX clock delay chain settings are board specific.
> +
> +Optional properties for "allwinner,sun8i-h3-emac":
> +- allwinner,use-internal-phy: Use the H3 SoC's internal E(thernet) PHY

Can't that be derived from the presence of the phy property?

> +- allwinner,leds-active-low: EPHY LEDs are active low

That also seems PHY related. Overall, I feel like we really need a phy
node for the internal phy.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--jy6Sn24JjFx/iggw--
