From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: Re: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Wed, 23 Dec 2015 19:35:37 +0100
Message-ID: <2375419.xULY4PYlNl@localhost>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com> <20151223.120425.2005941258192616350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: drivshin.allworx@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, hs@denx.de, mugunthanvnm@ti.com,
	kernel@iktek.de, dtrautmann@ibhsoftec-sps.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33982 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbbLWShi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 13:37:38 -0500
In-Reply-To: <20151223.120425.2005941258192616350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 December 2015 12:04:25 David Miller wrote:
> From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
> Date: Tue, 22 Dec 2015 19:36:31 -0500
> 
> > Testing by anyone who has real hardware using phy-handle or dual_emac
> > with fixed-link would be appreciated.
> 
> I'm going to wait for such testing before applying this series.
> 
> Thanks.

Successfully tested the following 3 configurations.
1. emac0 with phy_id and emac1 with fixed phy
2. emac0 with phy-handle and emac1 with fixed phy
3. emac0 with fixed phy and emac1 with fixed phy


Below are the affected DT nodes, with one cpsw_emac0 node choosen for each 
test.

&cpsw_emac0 {
	phy_id = <&davinci_mdio>, <5>;
	phy-mode = "mii";
	dual_emac_res_vlan = <4093>;
};

&cpsw_emac0 {
	phy-mode = "mii";
	dual_emac_res_vlan = <4093>;
	phy-handle = <&phy0>;
};

&cpsw_emac0 {
	phy-mode = "mii";
	dual_emac_res_vlan = <4093>;
	fixed-link {
		speed = <100>;
		full-duplex;
	};
};

&cpsw_emac1 {
	dual_emac_res_vlan = <4094>;
	phy-mode = "mii";
	fixed-link {
		speed = <100>;
		full-duplex;
	};
};

&davinci_mdio {
	status = "okay";
	phy0: ethernet-phy@0 {
		reg = <5>;
	};
};

ps: I don't have access to the board for the next 2 weeks.
