From: Michal Simek <monstr@monstr.eu>
Subject: Fwd: FW: Request guidance for supporting GMII to RGMII conversion in
 Linux MAC driver
Date: Tue, 5 Mar 2013 11:15:03 +0100
Message-ID: <CAHTX3d+EPfocjmu2_kEmW0jUDpuxgLj1U8Uagc1zeQvmkmXoTA@mail.gmail.com>
References: <59506B47DEDD3943ABF9AC60020F4E2921243CA2@XAP-PVEXMBX02.xlnx.xilinx.com>
	<f75b2440-5d94-4c5f-872d-8942f72d1a61@CO9EHSMHS023.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	Anirudha Sarangi <anirudh@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:50319 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549Ab3CEKPF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 05:15:05 -0500
Received: by mail-wg0-f46.google.com with SMTP id fg15so5277450wgb.25
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 02:15:03 -0800 (PST)
In-Reply-To: <f75b2440-5d94-4c5f-872d-8942f72d1a61@CO9EHSMHS023.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

just resent email to mailing list from Anirudha.



Hi,

I work for Xilinx and handle the Linux Ethernet controller drivers in X=
ilinx.

This email is regarding a concern that I have for one of our planned
HW implementation involving GMII to RGMII conversion.


Our HW team have developed a soft IP (will sit in the FPGA) which does
a GMII to RGMII conversion. The output from our Gig controller is GMII
data which is fed to this converter and the RGMII output from the
converter is fed to the PHY. The only concern here is that the
converter must know the link speed to do proper conversion. In a
typical case, the PHY autoneg happens between our PHY and the remote
PHY. At this point, the converter must know the negotiated speed.

In the existing implementation the converter has a register, to which
my Ethernet driver must write the negotiated speed. The Linux PHY
framework (drivers/net/phy) invokes the registered callback in my
driver  and my driver is expected to write to this converter register.

We have the following options:
- The converter sits on the same MDIO bus on which the PHY operates.
In my device tree I have a node for my MAC. In this node, I have a
node for mdio. Currently in this mdio node, we have just one entry for
my PHY. Now there will be one more entry added for the converter which
will have a mdio address. The device probe finds out the converter.
Then every time the link status change callback in my driver is called
from the Linux PHY framework, I need to write to this converter
register through the mdio. I have some options here. First option is,
create a dummy PHY driver with only one relevant API that writes to
the register the speed/duplex settings (and no other APIs
implemented). Second is just do a mdio write with speed/duplex setting
without creating a separate dummy PHY driver. The advantage with the
1st option is that the same converter core can be used with other MACs
and is like a separate entity different from the MAC driver. It=92s
functionally projected as a separate entity.
- The converter sits on a Axi_Lite interface not a MDIO bus. In the
device tree, it does not show up on a mdio bus. It shows up on the
Axi_Lite bus as a separate IP. Like previous case, we will either
directly write to the converter register over Axi_Lite or write a
small driver and provide read/write interface which the MAC driver can
use to write to the converter.


The MDIO implementation is simpler than Axi_Lite for this particular
implementation and uses lesser FPGA resource.

I just want to get opinion from the Linux maintainers as in future I
need to think of upstreaming the solution. I must know which of the
above will create lesser issues when I upstream.

Please advise me.

regards
Anirudha Sarangi

--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platfor=
m
