From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: am3359 (cpsw): unable to get gigabit link working (PHY: ICPlus
 IP1001)
Date: Thu, 14 Jun 2012 08:16:40 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9B6D3B@DBDE01.ent.ti.com>
References: <CAGm1_kurEedQc=5dR-mWPingRZcG9s0y9VDY=UijQC1X9RhJCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:35439 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab2FNIQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:16:46 -0400
In-Reply-To: <CAGm1_kurEedQc=5dR-mWPingRZcG9s0y9VDY=UijQC1X9RhJCw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Yegor Yefremov [mailto:yegorslists@googlemail.com]
> Sent: Wednesday, June 13, 2012 5:59 PM
> To: netdev
> Cc: Chemparathy, Cyril; Govindarajan, Sriramakrishnan; N, Mugunthan V
> Subject: am3359 (cpsw): unable to get gigabit link working (PHY: ICPlus
> IP1001)
> 
> I'm using a custom am3359 based board. The first CPSW ports is
> connected to ICPlus IP1001 phy via RGMII interface. I have no problem
> with 100mbit link, but as soon as I connect my board to a 1Gbit switch
> the communication fails. I can see that some data goes on wire, but
> switch refuses to forward it. I can't receive anything either. Phy
>. detects 1Gbit link correctly
> 
> My kernel: https://github.com/koenkooi/linux
> 
> I also define phy interface as RGMII:
> 
> static struct cpsw_slave_data am33xx_cpsw_slaves[] = {
>         {
>                 .slave_reg_ofs  = 0x208,
>                 .sliver_reg_ofs = 0xd80,
>                 .phy_id         = "0:02",
>                 .phy_if               = PHY_INTERFACE_MODE_RGMII,
>         },
>         {
>                 .slave_reg_ofs  = 0x308,
>                 .sliver_reg_ofs = 0xdc0,
>                 .phy_id         = "0:01",
>         },
> };
> 
> As far as I can see in the mainline cpsw driver
> PHY_INTERFACE_MODE_RGMII will be ignored. Why? In the current driver
> it sets two bits in mac_control register:
> 
> if (phy->interface == PHY_INTERFACE_MODE_RGMII) /* RGMII */
>                         mac_control |= (BIT(15)|BIT(16));
> 
> Any idea where should I look to solve the problem?

Phy interface in cpsw is always MII, there is an external gasket to convert from MII/GMII to RMII/RGMII. So this is a dead code resides in current driver and will be removed, that's why this part of code is not up streamed.

Can you verify the design/board layout with hardware engineer; also look for cpsw statistics counters for errors.

Regards,
Mugunthan V N. 
