From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Tue, 14 Feb 2017 15:53:13 +0100
Message-ID: <20170214155313.1e9a497b@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170107093834.GJ14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49368 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751376AbdBNOxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:53:16 -0500
In-Reply-To: <20170107093834.GJ14217@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sat, 7 Jan 2017 09:38:34 +0000, Russell King - ARM Linux wrote:

> This has the side effect that nothing clears the port reset bit in the
> GMAC, which means there's no hope of the interface working - with the
> reset bit set, the port is well and truely held in "link down" state.

Things were working fine here on Armada 7K/8K even without calling
mvpp21_port_power_up(port). But I've looked into more details, and in
fact the whole function makes sense on PPv2.2, except the
mvpp2_port_fc_adv_enable(port) part of it. So I've replaced this with:

	mvpp2_port_mii_set(port);
	mvpp2_port_periodic_xon_disable(port);

	if (priv->hw_version == MVPP21)
		mvpp2_port_fc_adv_enable(port);

	mvpp2_port_reset(port);

This will be in my v3.

> In any case, the GMAC part is much the same as mvneta, and I think
> that code should be shared rather than writing new versions of it.

Possibly, but it's really a separate thing: this is completely
independent from introducing PPv2.2 support, it's something that
already exists. The patch series is already 16 patches long in its v2,
and is going to even a bit longer in its v3, so I would really like to
stick to just PPv2.2 support.

Thanks!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
