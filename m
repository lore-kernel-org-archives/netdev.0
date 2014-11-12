From: Oliver Graute <oliver.graute@gmail.com>
Subject: Device Tree Binding for Marvell DSA Switch on imx28 board over Mdio Interface
Date: Wed, 12 Nov 2014 14:07:26 +0100
Message-ID: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38757 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaKLNH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 08:07:27 -0500
Received: by mail-ig0-f172.google.com with SMTP id a13so2870521igq.11
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 05:07:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

how do I specify the DSA node and the MDIO node in the Device Tree
Binding to integrate a Marvell 88e6071 switch with a imx28 board?

On my board the Marvell switch 88e6071 is connected via phy1 (on a
imx28 PCB) to phy5 on the Marvell switch (on a Switch PCB). All phys
are connected via the same MDIO Bus.

I enabled the Marvell DSA Support Driver, Gianfar Ethernet Driver and
Freescale PQ MDIO Driver in the Kernel (I' am not sure if this is the
right choice for imx28 fec ethernet controller is it?)

I already know that I need to adapt the DSA driver for this new
switch. But currently I can't access the switch ports because my MDIO
Bus is not configured correctly. It always ends with:

dmesg | grep -E "mii|dsa|mdio"
[    2.528900] libphy: fec_enet_mii_bus: probed
[    3.028061] !!!!Enter dsa Probe!!!!!
[    3.037640] !!!!!Enter dsa_of_probe!!!!!
[    3.041736] !!!!before of_parse_phandle dsa,mii-bus!!!!!
[    3.047123] !!!! mdio->name=ethernet-phy !!!!!
[    3.051658] !!!!before of_mdio_find_bus!!!!!
[    3.055950] !!!!!enter of_mdio_find_bus!!!!!
[    3.074074] !!!!!enter of_mdio_bus_match!!!!!
[    3.078451] !!!!!enter of_mdio_bus_match!!!!!
[    3.088915] !!!!Leave of_mdio_find_bus !!!!!
[    3.093268] !!!! return  of_mdio_find_bus =22 !!!!!
[    3.098166] dsa_of_probe returns=-22
[    3.101858] dsa: probe of dsa.5 failed with error -22
[   19.169423] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Micrel KSZ8041] (mii_bus:phy_addr=800f0000.etherne:00, irq=-1)
[   20.038786] fec 800f4000.ethernet eth1: Freescale FEC PHY driver
[Micrel KSZ8041] (mii_bus:phy_addr=800f0000.etherne:01, irq=-1)

because the method  of_mdio_find_bus returns with EINVAL

I suspect that the problem is the fact that the Kernel is not getting
connected to the MDIO bus.
what is wrong here?

dsa@0 {
        compatible = "marvell,dsa";
        #address-cells = <2>;
        #size-cells = <0>;
        interrupts = <10>;
        dsa,ethernet = <&eth1>;
         dsa,mii-bus = <&ethphy1>;

        switch@0 {
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <5 0>;   /* MDIO address 5, switch 0 in tree */

            port@0 {
                reg = <0>;
                label = "lan1";
                phy-handle = <&ethphy1>;
            };

            port@1 {
                reg = <1>;
                label = "lan2";
            };

            port@2 {
                reg = <2>;
                label = "lan3";
            };

            port@3 {
                reg = <3>;
                label = "lan4";
            };

            port@4 {
                reg = <4>;
                label = "lan5";
            };

            port@5 {
                reg = <5>;
                label = "cpu";
            };

        };
    };


eth1: eth1 {
    status = "okay";
    ethernet1-port@1 {
        phy-handle = <&ethphy1>;
    };
};


mdio_bus: mdio {
        #address-cells = <1>;
        #size-cells = <0>;
        device_type = "mdio";
        //compatible = "fsl,gianfar-mdio";
        compatible = "fsl,mpc875-fec-mdio", "fsl,pq1-fec-mdio";
        reg = <0xe00 0x188>;
        status = "okay";

         ethphy0: ethernet-phy@0 {
                 reg = <0>;

         };

         ethphy1: ethernet-phy@1 {
                 reg = <1>;
                };
                 //reg = <0xff>; */ /* No PHY attached */
                 //speed = <1000>;
                 //duple = <1>;
       };

Best regards,

Oliver Graute
