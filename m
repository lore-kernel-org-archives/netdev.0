From: Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH v5 09/11] dtb: xgene: Add MDIO node
Date: Mon, 1 Aug 2016 14:13:50 -0700
Message-ID: <CAOesGMiF0PQocy2jj9Fpz_K-dYRtJDnd789DOCLz35y5g+KVzw@mail.gmail.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com> <1467932579-14320-10-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467932579-14320-10-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I came across this now when looking at merge conflicts when preparing
this. I wish I had seen it sooner.

On Thu, Jul 7, 2016 at 4:02 PM, Iyappan Subramanian
<isubramanian-qTEPVZfXA3Y@public.gmane.org> wrote:
> Added mdio node for mdio driver.  Also added phy-handle
> reference to the ethernet nodes.
>
> Removed unused mdio subnode within storm menet ethernet node.
> Removed unused clock node from storm sgenet1.
>
> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Matthias Brugger <mbrugger-IBi9RG/b67k@public.gmane.org>
> ---
>  arch/arm64/boot/dts/apm/apm-mustang.dts | 12 +++++++++++
>  arch/arm64/boot/dts/apm/apm-storm.dtsi  | 36 ++++++++++++---------------------
>  2 files changed, 25 insertions(+), 23 deletions(-)
>
> diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
> index 44db32e..b7fb5d9 100644
> --- a/arch/arm64/boot/dts/apm/apm-mustang.dts
> +++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
> @@ -79,3 +79,15 @@
>  &mmc0 {
>         status = "ok";
>  };
> +
> +&mdio {
> +       menet0phy: phy@3 {
> +               reg = <0x3>;
> +       };
> +       sgenet0phy: phy@4 {
> +               reg = <0x4>;
> +       };
> +       sgenet1phy: phy@5 {
> +               reg = <0x5>;
> +       };
> +};
> diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> index 5147d76..a415b3a 100644
> --- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
> +++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> @@ -237,20 +237,11 @@
>                                 clocks = <&socplldiv2 0>;
>                                 reg = <0x0 0x1f21c000 0x0 0x1000>;
>                                 reg-names = "csr-reg";
> -                               csr-mask = <0x3>;
> +                               csr-mask = <0xa>;
> +                               enable-mask = <0xf>;
>                                 clock-output-names = "sge0clk";
>                         };
>
> -                       sge1clk: sge1clk@1f21c000 {
> -                               compatible = "apm,xgene-device-clock";
> -                               #clock-cells = <1>;
> -                               clocks = <&socplldiv2 0>;
> -                               reg = <0x0 0x1f21c000 0x0 0x1000>;
> -                               reg-names = "csr-reg";
> -                               csr-mask = <0xc>;
> -                               clock-output-names = "sge1clk";
> -                       };
> -
>                         xge0clk: xge0clk@1f61c000 {
>                                 compatible = "apm,xgene-device-clock";
>                                 #clock-cells = <1>;
> @@ -921,6 +912,14 @@
>                         clocks = <&rtcclk 0>;
>                 };
>
> +               mdio: mdio@0x17020000 {
> +                       compatible = "apm,xgene-mdio-rgmii";
> +                       #address-cells = <1>;
> +                       #size-cells = <0>;
> +                       reg = <0x0 0x17020000 0x0 0xd100>;
> +                       clocks = <&menetclk 0>;
> +               };
> +
>                 menet: ethernet@17020000 {


This new mmio node has the same unit address, and claims the same
register window as the ethernet controller.
That's doesn't seem correct?


-Olof
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
