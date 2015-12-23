From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Wed, 23 Dec 2015 16:51:50 -0500
Message-ID: <20151223165150.2f60d345.drivshin.allworx@gmail.com>
References: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
	<20151223.120425.2005941258192616350.davem@davemloft.net>
	<2375419.xULY4PYlNl@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, hs@denx.de, mugunthanvnm@ti.com,
	kernel@iktek.de, dtrautmann@ibhsoftec-sps.de
To: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36619 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbLWVvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 16:51:54 -0500
In-Reply-To: <2375419.xULY4PYlNl@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Dec 2015 19:35:37 +0100
Markus Brunner <systemprogrammierung.brunner@gmail.com> wrote:

> On Wednesday 23 December 2015 12:04:25 David Miller wrote:
> > From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
> > Date: Tue, 22 Dec 2015 19:36:31 -0500
> > 
> > > Testing by anyone who has real hardware using phy-handle or
> > > dual_emac with fixed-link would be appreciated.
> > 
> > I'm going to wait for such testing before applying this series.
> > 
> > Thanks.
> 
> Successfully tested the following 3 configurations.
> 1. emac0 with phy_id and emac1 with fixed phy
> 2. emac0 with phy-handle and emac1 with fixed phy
> 3. emac0 with fixed phy and emac1 with fixed phy

Great, thanks for testing. Using the same technique
for the phy-handle case as you, I also just tested:
 - (EVMSK) dual emac, phy-handle property in both slaves

I think that covers all the interesting cases.

Dave,
 I actually just received a note off-list reporting a problem  
with this series on the dm8148-t410 board. So please hold off  
applying this series for now. If it turns out to be a real  
problem I'll have a v2. 

[...]

> &davinci_mdio {
> 	status = "okay";
> 	phy0: ethernet-phy@0 {
> 		reg = <5>;
> 	};
> };

I was unaware that the davinci-mdio driver creates PHY devices
from child nodes. The davinci-mdio.txt binding documentation 
makes no mention of that. By comparison the emac_rockchip.txt 
file does talk about it.

Now that I take a closer look at the code, it looks like that 
capability was added in commit 0a0ea0687281 ("net: davinci_mdio: 
allow to create phys from dt"), but it didn't update the binding.

Grygorii, was that just an oversight, or capability that's not
supposed to be used? 
