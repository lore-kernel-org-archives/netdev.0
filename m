From: Peter Rosin <peda@axentia.se>
Subject: Re: [PATCH 10/10] net: mdio-sam: Add device tree documentation for
 SAM MDIO
Date: Mon, 10 Oct 2016 16:53:09 +0200
Message-ID: <aad9e8eb-2c15-3c83-067a-e76e0bc73e44@axentia.se>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-11-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Alexandre Courbot <gnurou@gmail.com>,
 devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 linux-watchdog@vger.kernel.org, Georgi Vlaev <gvlaev@juniper.net>,
 Wolfram Sang <wsa@the-dreams.de>, Maryam Seraj <mseraj@juniper.net>,
 David Woodhouse <dwmw2@infradead.org>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 linux-gpio@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
 Rob Herring <robh+dt@kernel.org>, linux-mtd@lists.infradead.org,
 Debjit Ghosh <dghosh@juniper.net>, netdev@vger.kernel.org,
 Brian Norris <computersforpeace@gmail.com>,
 Frank Rowand <frowand.list@gmail.com>, Guenter Roeck <linux@roeck-us.net>,
 linux-i2c@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@konsulko.com>, Lee Jones
 <lee.jones@linaro.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
In-Reply-To: <1475853518-22264-11-git-send-email-pantelis.antoniou@konsulko.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: "linux-mtd" <linux-mtd-bounces@lists.infradead.org>
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 2016-10-07 17:18, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev@juniper.net>
> 
> Add device tree bindings document for the SAM MDIO block
> present in Juniper's SAM FPGA.
> 
> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
> ---
>  Documentation/devicetree/bindings/net/mdio-sam.txt | 48 ++++++++++++++++++++++
>  1 file changed, 48 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/mdio-sam.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/mdio-sam.txt b/Documentation/devicetree/bindings/net/mdio-sam.txt
> new file mode 100644
> index 0000000..7d354e0
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mdio-sam.txt
> @@ -0,0 +1,48 @@
> +Juniper SAM FPGA MFD MDIO bus properties.
> +
> +Required properties:
> +- compatible : "jnx,mdio-sam"
> +- reg : The start offset of the MDIO bus range
> +- #address-cells = <1>;
> +- #size-cells = <0>;
> +
> +Optional properties:
> +
> +Required properties for child nodes:
> +- #address-cells = <1>;
> +- #size-cells = <0>;
> +- reg : The MDIO bus offset within the MDIO range.
> +
> +
> +Example :
> +
> +	sam@10 {
> +		compatible = "jnx,sam";
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		mdio-sam@10 {

This should be mdio-sam@40000, OR ...

> +			compatible = "jnx,mdio-sam";
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0x40000>;

... this should be reg = <0x10>. AFAIK.

Cheers,
Peter

> +
> +			mdio0: mdio-sam@0 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				reg = <0x0>;
> +			};
> +
> +			mdio1: mdio-sam@4000 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				reg = <0x4000>;
> +			};
> +
> +			mdio2: mdio-sam@8000 {
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				reg = <0x8000>;
> +			};
> +		};
> +	};
> 


______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
