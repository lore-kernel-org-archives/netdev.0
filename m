From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA on P1023RDB
Date: Mon, 16 Jun 2014 09:38:44 -0700
Message-ID: <CAGVrzcbxBE0yk5J1Pvkz5Yx+ugHTBjRSTLsvN9NACt20vjmgjw@mail.gmail.com>
References: <539F1B3F.6060203@xsmail.com> <539F1B8E.30503@xsmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pannirselvam Kanagaratnam <pannir@xsmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:58429 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272AbaFPQjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 12:39:24 -0400
Received: by mail-oa0-f47.google.com with SMTP id n16so6156160oag.6
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 09:39:24 -0700 (PDT)
In-Reply-To: <539F1B8E.30503@xsmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-16 9:30 GMT-07:00 Pannirselvam Kanagaratnam <pannir@xsmail.com>:
> Freescale's QORIQ P1023RDB has an option to populate the Marvell 88E6165
> Ethernet switch. We populated this device and were able to initialize it
> as a basic switch in U-Boot. However, the switch driver was not loaded
> upon kernel bootup. DSA kernel config was enabled for Marvell's 88E6165.
> The following patch was applied:
>
> http://patchwork.ozlabs.org/patch/230257/
> We are using Freescale's QorIQ-SDK-V1.5-20131219-yocto (3.8-r11.1). The
> switch is attached to phy address 0x3 via dtsec2. IRQ3 from the CPU is
> also physically connected to the switch (pin #122). My dts file is as
> below. Would appreciate any feedback on whether the DSA is structured
> correctly in the dts.
>
> The following mdio, mdio_bus and ethernet parameters were captured:
>
> 1) For mdio = of_parse_phandle(np, "dsa,mii-bus", 0); I get the following:
> np_name: dsa
> mdio_name: mdio
> mdio_type: <NULL>
> mdio_full-name: /soc@ff600000/fman@100000/mdio@e1120
>
> 2) mdio_bus = of_mdio_find_bus(mdio);
> mdio_bus_name: Freescale PowerQUICC MII Bus
> mdio_bus_id: mdio@ff7e1120
>
> 3) ethernet = of_parse_phandle(np, "dsa,ethernet", 0);
> ethernet-name: ethernet
> ethernet-type: <NULL>
> ethernet-full-name: /soc@ff600000/fman@100000/ethernet@e2000
>
> 4) ethernet_dev = of_find_device_by_node(ethernet);
> ethernet_dev-name: ff7e2000.ethernet
> ethernet_dev-id: -1

The id is -1 because this driver has been probed using device tree and
not using a non-device Tree platform device/driver which would set
explicit id numbers, this is not a problem here.

>
> Not sure why ethernet-dev-id is showing -1. Kindly advise. This is the
> output log during kernel booutp:
>
> Distributed Switch Architecture driver version 0.1
> dsa: probe of dsa.16 failed with error -22

This error might not come from dsa_of_probe(), please instrument the
code where -EINVAL is returned to see exactly which part of the
probing code is failing.

>
> Pannir
>
>
> /*
>  * P1023 RDB Device Tree Source
>  *
>  *    Copyright 2013 Freescale Semiconductor Inc.
>  *
>  * Author: Roy Zang <tie-fei.zang@freescale.com>
>  *       Chunhe Lan <Chunhe.Lan@freescale.com>
>  *
>  * Redistribution and use in source and binary forms, with or without
>  * modification, are permitted provided that the following conditions
> are met:
>  *     * Redistributions of source code must retain the above copyright
>  *       notice, this list of conditions and the following disclaimer.
>  *     * Redistributions in binary form must reproduce the above copyright
>  *       notice, this list of conditions and the following disclaimer
> in the
>  *       documentation and/or other materials provided with the
> distribution.
>  *     * Neither the name of Freescale Semiconductor nor the
>  *       names of its contributors may be used to endorse or promote
> products
>  *       derived from this software without specific prior written
> permission.
>  *
>  *
>  * ALTERNATIVELY, this software may be distributed under the terms of the
>  * GNU General Public License ("GPL") as published by the Free Software
>  * Foundation, either version 2 of that License or (at your option) any
>  * later version.
>  *
>  * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
>  * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
> IMPLIED
>  * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
>  * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
>  * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
> DAMAGES
>  * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
> SERVICES;
>  * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
> CAUSED AND
>  * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
> OR TORT
>  * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
> USE OF THIS
>  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>  */
>
> /include/ "fsl/p1023si-pre.dtsi"
>
> / {
>     model = "fsl,P1023";
>     compatible = "fsl,P1023RDB";
>     #address-cells = <2>;
>     #size-cells = <2>;
>     interrupt-parent = <&mpic>;
>
>     aliases {
>         ethernet0 = &enet0;
>         ethernet1 = &enet1;
>     };
>
>     memory {
>         device_type = "memory";
>     };
>
>     qportals: qman-portals@ff000000 {
>         ranges = <0x0 0xf 0xff000000 0x200000>;
>     };
>
>     bportals: bman-portals@ff200000 {
>         ranges = <0x0 0xf 0xff200000 0x200000>;
>     };
>
>     soc: soc@ff600000 {
>         ranges = <0x0 0x0 0xff600000 0x200000>;
>
>         i2c@3000 {
>             eeprom@53 {
>                 compatible = "at24,24c04";
>                 reg = <0x53>;
>             };
>
>             rtc@6f {
>                 compatible = "microchip,mcp7941x";
>                 reg = <0x6f>;
>             };
>         };
>
>         usb@22000 {
>             dr_mode = "host";
>             phy_type = "ulpi";
>         };
>
>         fman0: fman@100000 {
>             enet0: ethernet@e0000 {
>                 phy-handle = <&phy0>;
>                 phy-connection-type = "rgmii";
>             };
>             mdio0: mdio@e1120 {
>                 phy0: ethernet-phy@1 {
>                     reg = <0x01>;
>                 };
>                 tbi0: tbi-phy@8 {
>                     reg = <0x8>;
>                     device_type = "tbi-phy";
>                 };
>             };
>             enet1: ethernet@e2000 {
>                 fixed-link = <3 1 1000 0 0>;
>                 phy-connection-type = "rgmii-id";
>             };
>         };
>     };
>
>     lbc: localbus@ff605000 {
>         reg = <0 0xff605000 0 0x1000>;
>
>         /* NOR Flash */
>         ranges = <0x0 0x0 0x0 0xec000000 0x04000000>;
>
>         nor@0,0 {
>             #address-cells = <1>;
>             #size-cells = <1>;
>             compatible = "cfi-flash";
>             reg = <0x0 0x0 0x04000000>;
>             bank-width = <2>;
>             device-width = <1>;
>
>             partition@0 {
>                 label = "ramdisk";
>                 reg = <0x00000000 0x03000000>;
>             };
>             partition@3000000 {
>                 label = "kernel";
>                 reg = <0x03000000 0x00ee0000>;
>             };
>             partiton@3ee0000 {
>                 label = "dtb";
>                 reg = <0x03ee0000 0x00020000>;
>             };
>             partition@3f00000 {
>                 label = "firmware";
>                 reg = <0x03f00000 0x00080000>;
>                 read-only;
>             };
>             partition@3f80000 {
>                 label = "u-boot";
>                 reg = <0x03f80000 0x00080000>;
>                 read-only;
>             };
>         };
>     };
>
>     pci0: pcie@ff60a000 {
>         reg = <0 0xff60a000 0 0x1000>;
>         ranges = <0x2000000 0x0 0xc0000000 0 0xc0000000 0x0 0x20000000
>               0x1000000 0x0 0x00000000 0 0xffc20000 0x0 0x10000>;
>         pcie@0 {
>             /* IRQ[0:3] are pulled up on board, set to active-low */
>             interrupt-map-mask = <0xf800 0 0 7>;
>             interrupt-map = <
>                 /* IDSEL 0x0 */
>                 0000 0 0 1 &mpic 0 1 0 0
>                 0000 0 0 2 &mpic 1 1 0 0
>                 0000 0 0 3 &mpic 2 1 0 0
>                 0000 0 0 4 &mpic 3 1 0 0
>                 >;
>             ranges = <0x2000000 0x0 0xc0000000
>                   0x2000000 0x0 0xc0000000
>                   0x0 0x20000000
>
>                   0x1000000 0x0 0x0
>                   0x1000000 0x0 0x0
>                   0x0 0x100000>;
>         };
>     };
>
>     board_pci1: pci1: pcie@ff609000 {
>         reg = <0 0xff609000 0 0x1000>;
>         ranges = <0x2000000 0x0 0xa0000000 0 0xa0000000 0x0 0x20000000
>               0x1000000 0x0 0x00000000 0 0xffc10000 0x0 0x10000>;
>         pcie@0 {
>             /*
>              * IRQ[4:6] only for PCIe, set to active-high,
>              * IRQ[7] is pulled up on board, set to active-low
>              */
>             interrupt-map-mask = <0xf800 0 0 7>;
>             interrupt-map = <
>                 /* IDSEL 0x0 */
>                 0000 0 0 1 &mpic 4 2 0 0
>                 0000 0 0 2 &mpic 5 2 0 0
>                 0000 0 0 3 &mpic 6 2 0 0
>                 0000 0 0 4 &mpic 7 1 0 0
>                 >;
>             ranges = <0x2000000 0x0 0xa0000000
>                   0x2000000 0x0 0xa0000000
>                   0x0 0x20000000
>
>                   0x1000000 0x0 0x0
>                   0x1000000 0x0 0x0
>                   0x0 0x100000>;
>         };
>     };
>
>     pci2: pcie@ff60b000 {
>         reg = <0 0xff60b000 0 0x1000>;
>         ranges = <0x2000000 0x0 0x80000000 0 0x80000000 0x0 0x20000000
>               0x1000000 0x0 0x00000000 0 0xffc00000 0x0 0x10000>;
>         pcie@0 {
>             /*
>              * IRQ[8:10] are pulled up on board, set to active-low
>              * IRQ[11] only for PCIe, set to active-high,
>              */
>             interrupt-map-mask = <0xf800 0 0 7>;
>             interrupt-map = <
>                 /* IDSEL 0x0 */
>                 0000 0 0 1 &mpic 8 1 0 0
>                 0000 0 0 2 &mpic 9 1 0 0
>                 0000 0 0 3 &mpic 10 1 0 0
>                 0000 0 0 4 &mpic 11 2 0 0
>                 >;
>             ranges = <0x2000000 0x0 0x80000000
>                   0x2000000 0x0 0x80000000
>                   0x0 0x20000000
>
>                   0x1000000 0x0 0x0
>                   0x1000000 0x0 0x0
>                   0x0 0x100000>;
>         };
>     };
>
>     fsl,dpaa {
>         compatible = "fsl,p1023-dpaa", "fsl,dpaa";
>
>         ethernet@0 {
>             compatible = "fsl,p1023-dpa-ethernet", "fsl,dpa-ethernet";
>             fsl,fman-mac = <&enet0>;
>         };
>         ethernet@1 {
>             compatible = "fsl,p1023-dpa-ethernet", "fsl,dpa-ethernet";
>             fsl,fman-mac = <&enet1>;
>         };
>     };
>
>     dsa@0 {
>         compatible = "marvell,dsa";
>         #address-cells = <2>;
>         #size-cells = <0>;
>         interrupt-parent = <&mpic>;
>         interrupts = <3 1 0 0>;
>         dsa,ethernet = <&enet1>;
>         dsa,mii-bus = <&mdio0>;
>
>         switch@0 {
>             #address-cells = <1>;
>             #size-cells = <0>;
>             reg = <3 0>;    /* MDIO address 3, switch 0 in tree */
>
>             port@0 {
>                 reg = <0>;
>                 label = "lan1";
>             };
>
>             port@1 {
>                 reg = <1>;
>                 label = "lan2";
>             };
>
>             port@2 {
>                 reg = <2>;
>                 label = "lan3";
>             };
>
>             port@3 {
>                 reg = <3>;
>                 label = "lan4";
>             };
>
>             port@4 {
>                 reg = <4>;
>                 label = "lan5";
>             };
>
>             port@5 {
>                 reg = <5>;
>                 label = "cpu";
>             };
>
>         };
>
>     };
> };
>
> /include/ "fsl/p1023si-post.dtsi"
>
> /include/ "fsl/qoriq-dpaa-res2.dtsi"
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
