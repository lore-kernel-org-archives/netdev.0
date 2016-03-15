From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 15 Mar 2016 09:53:23 +0100
Message-ID: <87k2l4yvek.fsf@free-electrons.com>
References: <20160315110713.49c4846e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Olof Johansson <olof@lixom.net>,
	Marcin Wojtas <mw@semihalf.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160315110713.49c4846e@canb.auug.org.au> (Stephen Rothwell's
	message of "Tue, 15 Mar 2016 11:07:13 +1100")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,
 
 On mar., mars 15 2016, Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi all,
>
> Today's linux-next merge of the net-next tree got conflicts in:
>
>   arch/arm/boot/dts/armada-xp-db.dts
>   arch/arm/boot/dts/armada-xp-gp.dts
>   arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
>
> between commit:
>
>   d7d5a43c0d16 ("ARM: mvebu: fix overlap of Crypto SRAM with PCIe memory window")
>
> from Linus' tree and commits:
>
>   9dd7a57e2cbf ("ARM: dts: armada-xp: enable buffer manager support on Armada XP boards")
>   293fdc24fcc9 ("ARM: dts: armada-xp-openblocks-ax3-4: Add BM support")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

This fix is good, thanks!

Gregory

>
> -- 
> Cheers,
> Stephen Rothwell
>
> diff --cc arch/arm/boot/dts/armada-xp-db.dts
> index 45813a5526c8,30657302305d..000000000000
> --- a/arch/arm/boot/dts/armada-xp-db.dts
> +++ b/arch/arm/boot/dts/armada-xp-db.dts
> @@@ -76,8 -76,9 +76,9 @@@
>   		ranges = <MBUS_ID(0xf0, 0x01) 0 0 0xf1000000 0x100000
>   			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
>   			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x1000000
>  -			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
>  -			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
>  +			  MBUS_ID(0x09, 0x09) 0 0 0xf1100000 0x10000
> - 			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000>;
> ++			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000
> + 			  MBUS_ID(0x0c, 0x04) 0 0 0xf1200000 0x100000>;
>   
>   		devbus-bootcs {
>   			status = "okay";
> @@@ -229,34 -242,10 +242,38 @@@
>   					spi-max-frequency = <20000000>;
>   				};
>   			};
>  +
>  +			nand@d0000 {
>  +				status = "okay";
>  +				num-cs = <1>;
>  +				marvell,nand-keep-config;
>  +				marvell,nand-enable-arbiter;
>  +				nand-on-flash-bbt;
>  +
>  +				partitions {
>  +					compatible = "fixed-partitions";
>  +					#address-cells = <1>;
>  +					#size-cells = <1>;
>  +
>  +					partition@0 {
>  +						label = "U-Boot";
>  +						reg = <0 0x800000>;
>  +					};
>  +					partition@800000 {
>  +						label = "Linux";
>  +						reg = <0x800000 0x800000>;
>  +					};
>  +					partition@1000000 {
>  +						label = "Filesystem";
>  +						reg = <0x1000000 0x3f000000>;
>  +
>  +					};
>  +				};
>  +			};
>   		};
> + 
> + 		bm-bppi {
> + 			status = "okay";
> + 		};
>   	};
>   };
> diff --cc arch/arm/boot/dts/armada-xp-gp.dts
> index 5730b875c4f5,a1ded01d0c07..000000000000
> --- a/arch/arm/boot/dts/armada-xp-gp.dts
> +++ b/arch/arm/boot/dts/armada-xp-gp.dts
> @@@ -95,8 -95,9 +95,9 @@@
>   		ranges = <MBUS_ID(0xf0, 0x01) 0 0 0xf1000000 0x100000
>   			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
>   			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x1000000
>  -			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
>  -			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
>  +			  MBUS_ID(0x09, 0x09) 0 0 0xf1100000 0x10000
> - 			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000>;
> ++			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000
> + 			  MBUS_ID(0x0c, 0x04) 0 0 0xf1200000 0x100000>;
>   
>   		devbus-bootcs {
>   			status = "okay";
> diff --cc arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
> index 853bd392a4fe,3aa29a91c7b8..000000000000
> --- a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
> +++ b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
> @@@ -65,9 -65,10 +65,10 @@@
>   	soc {
>   		ranges = <MBUS_ID(0xf0, 0x01) 0 0 0xd0000000 0x100000
>   			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
>  -			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x8000000
>  -			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
>  -			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
>  +			  MBUS_ID(0x01, 0x2f) 0 0 0xe8000000 0x8000000
>  +			  MBUS_ID(0x09, 0x09) 0 0 0xf1100000 0x10000
> - 			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000>;
> ++			  MBUS_ID(0x09, 0x05) 0 0 0xf1110000 0x10000
> + 			  MBUS_ID(0x0c, 0x04) 0 0 0xd1200000 0x100000>;
>   
>   		devbus-bootcs {
>   			status = "okay";

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
