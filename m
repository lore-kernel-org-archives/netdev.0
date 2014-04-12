From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/4] Documentation: dts: Add bindings for APM X-Gene
 SoC ethernet driver
Date: Sat, 12 Apr 2014 11:55:03 -0700
Message-ID: <CAGVrzcbFHbZBaN1GsxViHaWsttU==2+9cf5mNRGwj9nbNxesVA@mail.gmail.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com> <1397271984-23405-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	jcm@redhat.com, Greg KH <gregkh@linuxfoundation.org>,
	patches@apm.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397271984-23405-3-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-11 20:06 GMT-07:00 Iyappan Subramanian <isubramanian@apm.com>:
> This patch adds documentation for APM X-Gene SoC ethernet DTS binding.
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Ravi Patel <rapatel@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> ---
>  .../devicetree/bindings/net/apm-xgene-enet.txt     |   46 ++++++++++++++++++++
>  1 file changed, 46 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt
>
> diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> new file mode 100644
> index 0000000..0c983e8
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
> @@ -0,0 +1,46 @@
> +APM X-Gene SoC Ethernet nodes
> +
> +Ethernet nodes are defined to describe on-chip ethernet interfaces in
> +APM X-Gene SoC.
> +
> +Required properties:
> +- compatible           : Should be "apm,xgene-enet"
> +- reg                  : First resource is the ethernet base register set
> +                         Second resource is the ring base register set
> +                         Third resource is the ring command register set
> +- interrupts           : Ethernet main interrupt
> +- clocks               : Reference to the clock entry.
> +- local-mac-address    : Ethernet MAC address.
> +- phy-addr             : Ethernet MII phy address.
> +- phy-mode             : Ethernet MII mode.
> +
> +Optional properties:
> +- status               : Should be "ok" or "disabled" for enabled/disabled.
> +                         Default is "ok".
> +
> +Example:
> +       menetclk: menetclk {
> +               compatible = "apm,xgene-device-clock";
> +               clock-output-names = "menetclk";
> +               status = "ok";
> +       };
> +
> +       menet: ethernet@17020000 {
> +               compatible = "apm,xgene-enet";
> +               status = "disabled";
> +               reg = <0x0 0x17020000 0x0 0xd100>,
> +                     <0x0 0X17030000 0x0 0X400>,
> +                     <0x0 0X10000000 0x0 0X200>;
> +               interrupts = <0x0 0x3c 0x4>;
> +               clocks = <&menetclk 0>;
> +               local-mac-address = [00 01 73 00 00 01];
> +               phy-addr = <3>;

An Ethernet PHY node needs to follow the ePAPR recommended
representation, which is not this one. Please refer to
Documentation/devicetree/bindinsg/net/phy.txt for examples on how to
do this properly.

> +               phy-mode = "rgmii";
> +       };
> +
> +
> +/* Board-specific peripheral configurations */
> +
> +&menet {
> +        status = "ok";
> +};
> --
> 1.7.9.5
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
