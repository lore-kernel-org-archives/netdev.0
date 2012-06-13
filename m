From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: am3359 (cpsw): unable to get gigabit link working (PHY: ICPlus IP1001)
Date: Wed, 13 Jun 2012 14:28:41 +0200
Message-ID: <CAGm1_kurEedQc=5dR-mWPingRZcG9s0y9VDY=UijQC1X9RhJCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cyril@ti.com, srk@ti.com, mugunthanvnm@ti.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:52781 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012Ab2FMM3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 08:29:03 -0400
Received: by gglu4 with SMTP id u4so325850ggl.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 05:29:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using a custom am3359 based board. The first CPSW ports is
connected to ICPlus IP1001 phy via RGMII interface. I have no problem
with 100mbit link, but as soon as I connect my board to a 1Gbit switch
the communication fails. I can see that some data goes on wire, but
switch refuses to forward it. I can't receive anything either. Phy
detects 1Gbit link correctly.

My kernel: https://github.com/koenkooi/linux

I also define phy interface as RGMII:

static struct cpsw_slave_data am33xx_cpsw_slaves[] = {
        {
                .slave_reg_ofs  = 0x208,
                .sliver_reg_ofs = 0xd80,
                .phy_id         = "0:02",
                .phy_if               = PHY_INTERFACE_MODE_RGMII,
        },
        {
                .slave_reg_ofs  = 0x308,
                .sliver_reg_ofs = 0xdc0,
                .phy_id         = "0:01",
        },
};

As far as I can see in the mainline cpsw driver
PHY_INTERFACE_MODE_RGMII will be ignored. Why? In the current driver
it sets two bits in mac_control register:

if (phy->interface == PHY_INTERFACE_MODE_RGMII) /* RGMII */
                        mac_control |= (BIT(15)|BIT(16));

Any idea where should I look to solve the problem?
