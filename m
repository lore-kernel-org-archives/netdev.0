From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Mon, 21 Aug 2017 16:23:21 +0200
Message-ID: <20170821142321.GE1703@lunn.ch>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170821133104.qvrhvwin2rdg4aqo-ZC1Zs529Oq4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> All muxes are mostly always represented the same way afaik, or do you
> want to simply introduce a new compatible / property?

+      	  mdio-mux {
+		compatible = "allwinner,sun8i-h3-mdio-switch";
+		mdio-parent-bus = <&mdio_parent>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		internal_mdio: mdio@1 {
			reg = <1>;
-			clocks = <&ccu CLK_BUS_EPHY>;
-			resets = <&ccu RST_BUS_EPHY>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			int_mii_phy: ethernet-phy@1 {
+				compatible = "ethernet-phy-ieee802.3-c22";
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+				phy-is-integrated;
+			};
+		};
+		mdio: mdio@0 {
+			reg = <0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
 		};
 		
Hi Maxim

Anybody who knows the MDIO-mux code/binding, knows that it is a run
time mux. You swap the mux per MDIO transaction. You can access all
the PHY and switches on the mux'ed MDIO bus.

However here, it is effectively a boot-time MUX. You cannot change it
on the fly. What happens when somebody has a phandle to a PHY on the
internal and a phandle to a phy on the external? Does the driver at
least return -EINVAL, or -EBUSY? Is there a representation which
eliminates this possibility?

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
