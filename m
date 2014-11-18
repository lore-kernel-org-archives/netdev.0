From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA Switch on imx28 board over
 Mdio Interface
Date: Tue, 18 Nov 2014 10:23:14 -0800
Message-ID: <546B8E92.7080000@gmail.com>
References: <CA+KjHfYZdZ88ZFzFCPN-bGphh+mnSWy6i0WNzFYv=gOsafXA7g@mail.gmail.com>	<5463B2AC.6090904@gmail.com>	<CA+KjHfbwtwPFXFEVDDijRNeTcHcSn0BZ4_yGuwcgyFfubNFCQA@mail.gmail.com>	<54650E9C.7080708@gmail.com>	<CA+KjHfZSeM=CPxbpoTAjbC3S5EKw+M59hii3t2zY4HePmFGZYg@mail.gmail.com>	<CA+KjHfa=Tqs=CWe6TT+rbmc9UaFZghqW1OtigPm9wOyXgN2AOQ@mail.gmail.com>	<CA+KjHfY13ynH4Zr5Cerhswo3eucj3DMwq0tZ5CQquT3yuxKv-Q@mail.gmail.com>	<20141117160934.GR2001@lunn.ch> <CA+KjHfauqO=BxOogexO3azW27cb1gHqEL5Mh-c+qxfUMYvf_mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	buytenh@wantstofly.org
To: Oliver Graute <oliver.graute@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:53467 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbaKRSXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 13:23:24 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so4169750pac.25
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 10:23:24 -0800 (PST)
In-Reply-To: <CA+KjHfauqO=BxOogexO3azW27cb1gHqEL5Mh-c+qxfUMYvf_mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2014 12:30 AM, Oliver Graute wrote:
>> Hi Oliver
>>
>> How do you have the strapping pins on the switch set? They determine
>> what address on the mdio bus the chip responds to.
> 
> On the circuit diagram the PIN 54  (P5_IND1/P5ID1) is set to
> "Configuration Address: 0101"
> P5_MODE[3:0]=0111 = Single RMII MAC Mode (100Mbps FD with 50 MHz clock input)
> PIN 59 R1_LED/NO_CPU Configuration: CPU is attached SMI address is 0x10 to 0x1F
> 
> But what is the mdio address of the whole switch? or can I only
> address individual phy ports?

You should specify in the Device Tree the switch pseudo-PHY address,
typically 16 for Marvell switches. You can still access the individual
ports' PHY addresses using address 0 through N.

> 
> The Port 5 Pins of the  Marvell 88e6071 switch are connected via RMII
> to a Micrel Phy KSZ8051. And this Micrel Phy is connected to the MAC
> of IMX28 CPU (also RMII).
> 
>> Does your u-boot have commands to read arbitrary phy registers?
>> Generally, reading a register that does not exist gives 0xffff.  So
>> try some reads at different addresses and see what you can find.
> 
> I can read phy registers from the Marvell switch by a Tool called
> mii_demo it is a bit like mii_diag. It can read PHY registers from the
> switch Ports via IOCTL.
> This is working via some undefined ioctl SIOCSMIIREG2, SIOCGMIIPHY2.
> 
> 
> Example:
> #read SMI PHY Command Register 18 from Switch with IEEE 802.3 Clause 22
> mii_demo -rd eth0 23 0x18
> 
> 0x1680
> 
> Best regards,
> 
> Oliver
> 
