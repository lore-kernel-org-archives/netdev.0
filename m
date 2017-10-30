From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [REGRESSION, BISECTED] Broken networking with net/phy/marvell
Date: Mon, 30 Oct 2017 02:19:54 +0200
Message-ID: <20171030001954.rlrbldsle7v5ti5p@darkstar.musicnaut.iki.fi>
References: <20171026122836.zoggs44rkasflr3m@darkstar.musicnaut.iki.fi>
 <20171028190139.GA17645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh03.mail.saunalahti.fi ([62.142.5.109]:38484 "EHLO
        emh03.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdJ3AT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 20:19:58 -0400
Content-Disposition: inline
In-Reply-To: <20171028190139.GA17645@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Oct 28, 2017 at 09:01:39PM +0200, Andrew Lunn wrote:
> On Thu, Oct 26, 2017 at 03:28:36PM +0300, Aaro Koskinen wrote:
> > When upgrading from v4.13 to v4.14-rc6 on OpenRD Client, the box loses
> > network connectivity.
> 
> What exactly is the PHY in the OpenRD?

88E1116R.

> Please can you print the value of mscr before it is changed.

[    3.377836] MSCR BEFORE: 00001070
[    3.381176]  MSCR AFTER: 00001040

> One possibility, is that the bootloader is setting the PHY to
> rgmii-id. This is now getting cleared, where earlier it was
> preserved. If this is true, it should be solved by adding
> 
> phy-mode = "rgmii-id" to the ethernet node in the device tree.

Ok, that seems to help:

[    3.377852] MSCR BEFORE: 00001070
[    3.381189]  MSCR AFTER: 00001070

diff --git a/arch/arm/boot/dts/kirkwood-openrd-client.dts b/arch/arm/boot/dts/kirkwood-openrd-client.dts
index 96ff59d..2bf3cb3 100644
--- a/arch/arm/boot/dts/kirkwood-openrd-client.dts
+++ b/arch/arm/boot/dts/kirkwood-openrd-client.dts
@@ -65,6 +65,7 @@
 	status = "okay";
 	ethernet0-port@0 {
 		phy-handle = <&ethphy0>;
+		phy-mode = "rgmii-id";
 	};
 };
 
@@ -72,6 +73,7 @@
 	status = "okay";
 	ethernet1-port@0 {
 		phy-handle = <&ethphy1>;
+		phy-mode = "rgmii-id";
 	};
 };

A.
