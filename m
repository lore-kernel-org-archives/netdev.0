From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Thu, 12 Jan 2017 02:06:58 +0100
Message-ID: <20170112010658.GA25391@lunn.ch>
References: <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
 <20170111225948.GH13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
 <20170111232200.GI13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B66@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57871 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935867AbdALBHD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 20:07:03 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354B66@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> I double checked that ours is actually a 88E1514. According
> to Marvell's brief description, it seems that it does support
> fiber.
> 
> Reading page 18 reg 30 returns 6.

O.K, that is consistent. Looking at the Marvell SDK:

phy/Include/madApiDefs.h:#define    MAD_SUB_88E1510  4   /* 88E1510 */
phy/Include/madApiDefs.h:#define    MAD_SUB_88E1518  5   /* 88E1518 */
phy/Include/madApiDefs.h:#define    MAD_SUB_88E1512  6   /* 88E1512/88E1514 */

I took another look at the patch adding Fibre support. The
suspend/resume functions are wrong.

        /* Suspend the fiber mode first */
        if (!(phydev->supported & SUPPORTED_FIBRE)) {
 
The ! should not be there. Does removing them both fix your problem?

    Andrew
