From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/7] ARM: STi: DT: STiH410: Add usb2 picophy dt nodes
Date: Mon, 01 Dec 2014 16:40:35 +0100
Message-ID: <4736928.ouoSJRV5Ml@wuerfel>
References: <1416385632-5832-1-git-send-email-peter.griffin@linaro.org> <1416385632-5832-5-git-send-email-peter.griffin@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Peter Griffin <peter.griffin@linaro.org>,
	linux-kernel@vger.kernel.org, srinivas.kandagatla@gmail.com,
	maxime.coquelin@st.com, patrice.chotard@st.com,
	peppe.cavallaro@st.com, kishon@ti.com, netdev@vger.kernel.org,
	lee.jones@linaro.org, alexandre.torgue@st.com,
	devicetree@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416385632-5832-5-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 November 2014 08:27:09 Peter Griffin wrote:
> +       soc {
> +               usb2_picophy1: phy@1 {
> +                       compatible = "st,stih407-usb2-phy";
> +                       #phy-cells = <0>;
> +                       st,syscfg = <&syscfg_core 0xf8 0xf4>;
> +                       resets = <&softreset STIH407_PICOPHY_SOFTRESET>,
> +                                <&picophyreset STIH407_PICOPHY0_RESET>;
> +                       reset-names = "global", "port";
> +               };
>  
> +               usb2_picophy2: phy@2 {
> +                       compatible = "st,stih407-usb2-phy";
> +                       #phy-cells = <0>;
> +                       st,syscfg = <&syscfg_core 0xfc 0xf4>;
> +                       resets = <&softreset STIH407_PICOPHY_SOFTRESET>,
> +                                <&picophyreset STIH407_PICOPHY1_RESET>;
> +                       reset-names = "global", "port";
> +               };
> +       };

In theory the unit-address (the @1 and @2 part of the name) is supposed to
match the 'reg' property value, but of course that doesn't work any
more with the changed binding. The same problem keeps coming up, so
I wonder if anyone has an idea how this is supposed to be handled properly.

Should we just make up unit-address numbers? I guess a more elaborate
variant would be to have a parent node with #address-cells = <1> and
no ranges, to make up a new address space with arbitrarily assigned
reg values, like

	phys {
		#address-cells = <1>; /* just counting the nodes */
		#size-cells = <0>;

               usb2_picophy1: phy@0 {
                       compatible = "st,stih407-usb2-phy";
			reg = <0>;
                       #phy-cells = <0>;
                       st,syscfg = <&syscfg_core 0xf8 0xf4>;
               };

               usb2_picophy2: phy@1 {
                       compatible = "st,stih407-usb2-phy";
			reg = <0>;
                       #phy-cells = <0>;
                       st,syscfg = <&syscfg_core 0xf8 0xf4>;
               };
	}

Should we try to do it like this, or is that overcomplicating
things?

	Arnd
