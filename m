From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
Date: Mon, 21 Dec 2009 08:27:05 +0100
Message-ID: <20091221072704.GA12110@gibson.comsick.at>
References: <20091220214447.GA10233@trillian.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: netdev <netdev@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:58803
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702AbZLUH1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 02:27:19 -0500
Content-Disposition: inline
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 21 Dec 09 09:58, Kumar Gopalpet-B05799 wrote:
> Hi Michael,
> 
> It looks like even we are enabling only single tx queue, some how it is
> trying to pick up tx queue 66. 
> 
> Can you please let me know what is your test setup and, please give me
The hardware used is a Mikrotik Routerboard RB600a, which is 83xx based.
It has three NICs two of them being gianfar devices.

> the location from where you cloned this kernel. 
The kernel used is vanilla 2.6.33-rc1 from git.kernel.org plus the Board
specific patches. The patches do not change anything on the network or
driver side, they just add ATA, nand and board specific support to the
kernel. If you want I can provide a git repo for it.

> Can you also share the dts file you were using ?
Attached you will find the DTS file being used.

Kind regards,
Michael


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="rb600.dts"

/*
 * Routerboard RB600 Device Tree Source
 */

/dts-v1/;

/ {
	model = "RB600";
	compatible = "MPC83xx";
	#address-cells = <1>;
	#size-cells = <1>;

	aliases {
		ethernet0 = &enet0;
		ethernet1 = &enet1;
	};


	chosen {
		linux,stdout-path = "/soc8343@e0000000/serial@4500";
	};

	cpus {
		#address-cells = <1>;
		#size-cells = <0>;

		PowerPC,8343E@0 {
			device_type = "cpu";
			reg = <0x0>;
			d-cache-line-size = <0x20>;
			i-cache-line-size = <0x20>;
			d-cache-size = <0x8000>;
			i-cache-size = <0x8000>;
			timebase-frequency = <0x0000000>; // filled by the bootwrapper from the firmware blob
			clock-frequency = <0x00000000>; // filled by the bootwrapper from the firmware blob
		};
	};

	memory {
		device_type = "memory";
		reg = <0x0 0x0000000>; // filled by the bootwrapper from the firmware blob
	};

	cf@f9200000 {
		lb-timings = <0x5dc 0x3e8 0x1194 0x5dc 0x2af8>;
		interrupt-at-level = <0x0>;
		interrupt-parent = <&ipic>;
		interrupts = <0x16 0x8>;
		lbc_extra_divider = <0x1>;
		reg = <0xf9200000 0x200000>;
		device_type = "rb,cf";
	};

	cf@f9000000 {
		lb-timings = <0x5dc 0x3e8 0x1194 0x5dc 0x2af8>;
		interrupt-at-level = <0x0>;
		interrupt-parent = <&ipic>;
		interrupts = <0x14 0x8>;
		lbc_extra_divider = <0x1>;
		reg = <0xf9000000 0x200000>;
		device_type = "rb,cf";
	};

	flash {
		reg = <0xff800000 0x20000>;
	};

	nnand {
		reg = <0xf0000000 0x1000>;
	};

	nand {
		ale = <&gpio 0x6>;
		cle = <&gpio 0x5>;
		nce = <&gpio 0x4>;
		rdy = <&gpio 0x3>;
		reg = <0xf8000000 0x1000>;
		device_type = "rb,nand";
	};

	fancon {
		interrupt-parent = <&ipic>;
		interrupts = <0x17 0x8>;
		sense = <&gpio 0x7>;
		fan_on = <&gpio 0x9>;
	};

	pci0: pci@e0008500 {
		device_type = "pci";
		compatible = "fsl,mpc8349-pci";
		reg = <0xe0008500 0x100 0xe0008300 0x8>;
		#address-cells = <3>;
		#size-cells = <2>;
		#interrupt-cells = <1>;
		ranges = <0x2000000 0x0 0x80000000 0x80000000 0x0 0x20000000 0x1000000 0x0 0x0 0xd0000000 0x0 0x4000000>;
		bus-range = <0x0 0x0>;
		interrupt-map = <
		0x5800 0x0 0x0 0x1 &ipic 0x15 0x8
		0x6000 0x0 0x0 0x1 &ipic 0x30 0x8
		0x6000 0x0 0x0 0x2 &ipic 0x11 0x8
		0x6800 0x0 0x0 0x1 &ipic 0x11 0x8
		0x6800 0x0 0x0 0x2 &ipic 0x12 0x8
		0x7000 0x0 0x0 0x1 &ipic 0x12 0x8
		0x7000 0x0 0x0 0x2 &ipic 0x13 0x8
		0x7800 0x0 0x0 0x1 &ipic 0x13 0x8
		0x7800 0x0 0x0 0x2 &ipic 0x30 0x8
		0x8000 0x0 0x0 0x1 &ipic 0x30 0x8
		0x8000 0x0 0x0 0x2 &ipic 0x12 0x8
		0x8000 0x0 0x0 0x3 &ipic 0x11 0x8
		0x8000 0x0 0x0 0x4 &ipic 0x13 0x8
		0xa000 0x0 0x0 0x1 &ipic 0x30 0x8
		0xa000 0x0 0x0 0x2 &ipic 0x11 0x8
		0xa000 0x0 0x0 0x3 &ipic 0x12 0x8
		0xa000 0x0 0x0 0x4 &ipic 0x13 0x8
		0xa800 0x0 0x0 0x1 &ipic 0x11 0x8
		0xa800 0x0 0x0 0x2 &ipic 0x12 0x8
		0xa800 0x0 0x0 0x3 &ipic 0x13 0x8
		0xa800 0x0 0x0 0x4 &ipic 0x30 0x8>;
		interrupt-map-mask = <0xf800 0x0 0x0 0x7>;
		interrupt-parent = <&ipic>;
		};


	soc8343@e0000000 {
		#address-cells = <1>;
		#size-cells = <1>;
		device_type = "soc";
		compatible = "simple-bus";
		ranges = <0x0 0xe0000000 0x100000>;
		reg = <0xe0000000 0x200>;
		bus-frequency = <0x1>;

		led {
			user_led = <&gpio 0x8>;
		};

		beeper {
			reg = <0x500 0x100>;
		};

		gpio: gpio@0 {
			#gpio-cells = <2>;
			compatible = "fsl,mpc8349-gpio";
			reg = <0xc08 0x4>;
			interrupt-parent = <&ipic>;
			gpio-controller;
		};

		enet0: ethernet@25000 {
			#address-cells = <1>;
			#size-cells = <1>;
			cell-index = <0>;
			phy-handle = <&phy0>;
			tbi-handle = <&tbi0>;
			interrupt-parent = <&ipic>;
			interrupts = <0x23 0x8 0x24 0x8 0x25 0x8>;
			local-mac-address = [00 00 00 00 00 00];
			reg = <0x25000 0x1000>;
			ranges = <0x0 0x25000 0x1000>;
			compatible = "gianfar";
			model = "TSEC";
			device_type = "network";

			mdio@520 {
				#address-cells = <1>;
				#size-cells = <0>;
				compatible = "fsl,gianfar-tbi";
				reg = <0x520 0x20>;

				tbi0: tbi-phy@11 {
					reg = <0x11>;
					device_type = "tbi-phy";
				};
			};
		};

		enet1: ethernet@24000 {
			#address-cells = <1>;
			#size-cells = <1>;
			cell-index = <1>;
			phy-handle = <&phy1>;
			tbi-handle = <&tbi1>;
			interrupt-parent = <&ipic>;
			interrupts = <0x20 0x8 0x21 0x8 0x22 0x8>;
			local-mac-address = [00 00 00 00 00 00];
			reg = <0x24000 0x1000>;
			ranges = <0x0 0x24000 0x1000>;
			compatible = "gianfar";
			model = "TSEC";
			device_type = "network";

			mdio@520 {
				#size-cells = <0x0>;
				#address-cells = <0x1>;
				reg = <0x520 0x20>;
				compatible = "fsl,gianfar-mdio";

				phy0: ethernet-phy@0 {
					device_type = "ethernet-phy";
					reg = <0x0>;
				};

				phy1: ethernet-phy@1 {
					device_type = "ethernet-phy";
					reg = <0x1>;
				};

				tbi1: tbi-phy@11 {
					reg = <0x11>;
					device_type = "tbi-phy";
				};
			};
		};



		ipic: pic@700 {
			interrupt-controller;
			#address-cells = <0>;
			#interrupt-cells = <2>;
			reg = <0x700 0x100>;
			device_type = "ipic";
		};

		serial@4500 {
			interrupt-parent = <&ipic>;
			interrupts = <0x9 0x8>;
			clock-frequency = <0xfe4f840>;
			reg = <0x4500 0x100>;
			compatible = "ns16550";
			device_type = "serial";
		};

		wdt@200 {
			reg = <0x200 0x100>;
			compatible = "mpc83xx_wdt";
			device_type = "watchdog";
		};
	};
};

--CE+1k2dSO48ffgeK--
