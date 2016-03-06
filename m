From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v4 net-next 2/9] ARM: dts: armada-38x: enable buffer
 manager support on Armada 38x boards
Date: Sun, 6 Mar 2016 20:35:34 +0000
Message-ID: <20160306203534.GH19428@n2100.arm.linux.org.uk>
References: <1457217507-10778-1-git-send-email-gregory.clement@free-electrons.com>
 <1457217507-10778-3-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457217507-10778-3-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2016 at 11:38:20PM +0100, Gregory CLEMENT wrote:
> From: Marcin Wojtas <mw@semihalf.com>
> 
> Since mvneta driver supports using hardware buffer management (BM), in
> order to use it, board files have to be adjusted accordingly. This commit
> enables BM on:
> * A385-DB-AP - each port has its own pool for long and common pool for
> short packets,
> * A388-ClearFog - same as above,

I'm mostly happy with the change to these two files below, but I do
wonder whether the structuring is correct: I'm not sure what SR's
long term plans are for the A388 microsom, and what other
configurations it could end up being used with, and whether that would
affect the split between the new BM configuration in the clearfog and
microsom files.  We can always sort that out later once it becomes
better known.  So, for clearfog:

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>

Thanks.

> diff --git a/arch/arm/boot/dts/armada-388-clearfog.dts b/arch/arm/boot/dts/armada-388-clearfog.dts
> index c6e180eb3b11..c60206efb583 100644
> --- a/arch/arm/boot/dts/armada-388-clearfog.dts
> +++ b/arch/arm/boot/dts/armada-388-clearfog.dts
> @@ -78,6 +78,9 @@
>  		internal-regs {
>  			ethernet@30000 {
>  				phy-mode = "sgmii";
> +				buffer-manager = <&bm>;
> +				bm,pool-long = <2>;
> +				bm,pool-short = <1>;
>  				status = "okay";
>  
>  				fixed-link {
> @@ -88,6 +91,9 @@
>  
>  			ethernet@34000 {
>  				phy-mode = "sgmii";
> +				buffer-manager = <&bm>;
> +				bm,pool-long = <3>;
> +				bm,pool-short = <1>;
>  				status = "okay";
>  
>  				fixed-link {
...
> diff --git a/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi b/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
> index 3f792a563c05..8c9842237b60 100644
> --- a/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
> +++ b/arch/arm/boot/dts/armada-38x-solidrun-microsom.dtsi
> @@ -58,7 +58,8 @@
>  		ranges = <MBUS_ID(0xf0, 0x01) 0 0xf1000000 0x100000
>  			  MBUS_ID(0x01, 0x1d) 0 0xfff00000 0x100000
>  			  MBUS_ID(0x09, 0x19) 0 0xf1100000 0x10000
> -			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000>;
> +			  MBUS_ID(0x09, 0x15) 0 0xf1110000 0x10000
> +			  MBUS_ID(0x0c, 0x04) 0 0xf1200000 0x100000>;
>  
>  		internal-regs {
>  			ethernet@70000 {
> @@ -66,6 +67,9 @@
>  				pinctrl-names = "default";
>  				phy = <&phy_dedicated>;
>  				phy-mode = "rgmii-id";
> +				buffer-manager = <&bm>;
> +				bm,pool-long = <0>;
> +				bm,pool-short = <1>;
>  				status = "okay";
>  			};
>  
> @@ -110,6 +114,15 @@
>  				pinctrl-names = "default";
>  				status = "okay";
>  			};
> +
> +			bm@c8000 {
> +				status = "okay";
> +			};
>  		};
> +
> +		bm-bppi {
> +			status = "okay";
> +		};
> +
>  	};
>  };

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
