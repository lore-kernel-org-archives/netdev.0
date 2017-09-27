From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v6 06/11] ARM: dts: sunxi: h3/h5: represent
 the mdio switch used by sun8i-h3-emac
Date: Wed, 27 Sep 2017 12:16:22 +0200
Message-ID: <20170927101622.v7odmreccwh7ldg2@flea>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
 <20170927073414.17361-7-clabbe.montjoie@gmail.com>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cn4zez4ijobb7pzg"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBAPVVXHAKGQE7JSPJII-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170927073414.17361-7-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--cn4zez4ijobb7pzg
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline

On Wed, Sep 27, 2017 at 07:34:09AM +0000, Corentin Labbe wrote:
> Since dwmac-sun8i could use either an integrated PHY or an external PHY
> (which could be at same MDIO address), we need to represent this selection
> by a MDIO switch.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 31 +++++++++++++++++++++++++------
>  1 file changed, 25 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> index 3b7d953429a6..a8e9b8f378ba 100644
> --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> @@ -422,14 +422,33 @@
>  			#size-cells = <0>;
>  			status = "disabled";
>  
> -			mdio: mdio {
> +			mdio0: mdio {
>  				#address-cells = <1>;
>  				#size-cells = <0>;
> -				int_mii_phy: ethernet-phy@1 {
> -					compatible = "ethernet-phy-ieee802.3-c22";
> -					reg = <1>;
> -					clocks = <&ccu CLK_BUS_EPHY>;
> -					resets = <&ccu RST_BUS_EPHY>;
> +				compatible = "snps,dwmac-mdio";
> +
> +				mdio-mux {
> +					compatible = "mdio-mux";
> +					#address-cells = <1>;
> +					#size-cells = <0>;

Newline

> +					/* Only one MDIO is usable at the time */
> +					internal_mdio: mdio@1 {
> +						reg = <1>;
> +						#address-cells = <1>;
> +						#size-cells = <0>;

Newline

> +						int_mii_phy: ethernet-phy@1 {
> +							compatible = "ethernet-phy-ieee802.3-c22";
> +							reg = <1>;
> +							clocks = <&ccu CLK_BUS_EPHY>;
> +							resets = <&ccu RST_BUS_EPHY>;
> +							phy-is-integrated;
> +						};
> +					};

Newline

> +					mdio: mdio@2 {

This is quite confusing. Why not call the label external_mdio?

Thanks

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--cn4zez4ijobb7pzg--
