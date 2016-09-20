From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5
 SoCs
Date: Tue, 20 Sep 2016 22:13:14 +1000
Message-ID: <1474373594.2857.62.camel@kernel.crashing.org>
References: <20160920063007.24291-1-joel@jms.id.au>
         <20160920063007.24291-7-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: gwshan@linux.vnet.ibm.com, andrew@lunn.ch, andrew@aj.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joel Stanley <joel@jms.id.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36349 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751257AbcITMNj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 08:13:39 -0400
In-Reply-To: <20160920063007.24291-7-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 16:00 +0930, Joel Stanley wrote:
> On Aspeed SoC with a direct PHY connection (non-NSCI), we receive
> continual PHYSTS interrupts:
> 
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
> 
> This is because the driver was enabling low-level sensitive interrupt
> generation where the systems are wired for high-level. All CPU cycles
> are spent servicing this interrupt.

If this is a system wiring issue, should it be represented by a DT
property ?

Cheers,
Ben.
