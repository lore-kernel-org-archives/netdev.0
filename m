From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 01/16] dt-bindings: net: update Marvell PPv2
 binding for PPv2.2 support
Date: Thu, 2 Feb 2017 17:56:50 +0100
Message-ID: <20170202175650.1fc06c2d@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943592-12556-2-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170103201842.hdg2uzzesog2jund@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Pawel Moll <pawel.moll@arm.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Kumar Gala <galak@codeaurora.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:57350 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752225AbdBBQ5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:57:00 -0500
In-Reply-To: <20170103201842.hdg2uzzesog2jund@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, 3 Jan 2017 14:18:42 -0600, Rob Herring wrote:

> > +- port-id: ID of the port from the MAC point of view
> > +- gop-port-id: only for marvell,armada-7k-pp2, ID of the port from the
> > +  GOP (Group Of Ports) point of view  
> 
> What GOP is needs a better explanation. Why doesn't 375 need this?

GOP stands for "group of ports", it's one of the HW component inside
the PPv2 IP.

Armada 375 also has the same GOP, but we described the registers in a
different way for Armada 375, with one reg entry per port:

        reg = <0xf0000 0xa000>,
              <0xc0000 0x3060>,
              <0xc4000 0x100>,
              <0xc5000 0x100>;

The last two entries are the per-port registers for eth0 and eth1.

For PPv2.2, we wanted to simplify a little bit the register mappings,
and simply reflect the memory map of the SoC. In the SoC datasheet,
there are two memory areas for the networking subsystem, which are the
two areas reflected in:

        reg = <0x0 0x100000>,
              <0x100000 0x80000>;

The per-port registers are inside the second register area. But by
exposing the entire register area in the Device Tree binding, we allow
improvements in the driver that need additional registers to be made
without changing the Device Tree description of the device.

> > +Example for marvell,armada-7k-pp2:
> > +
> > +cpm_ethernet: ethernet@0 {
> > +	compatible = "marvell,armada-7k-pp22";
> > +	reg = <0x0 0x100000>,
> > +	      <0x100000 0x80000>;
> > +	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
> > +	clock-names = "pp_clk", "gop_clk", "gp_clk";
> > +	status = "disabled";  
> 
> Drop status from examples.

OK, so I'll have to adjust this for the existing armada-375-pp2 example
as well.

> > +
> > +	eth0: eth@0 {  
> 
> unit address requires a reg property. Or this can be 'eth0' instead.

Same here, the sub-nodes don't have a reg property for armada-375-pp2,
so I guess this comment applies as well, right?

Thanks for your feedback!

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
