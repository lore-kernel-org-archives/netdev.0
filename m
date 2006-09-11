From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: TG3 data corruption (TSO ?)
Date: Mon, 11 Sep 2006 15:52:05 +1000
Message-ID: <1157953925.31071.413.camel@localhost.localdomain>
References: <1551EAE59135BE47B544934E30FC4FC093FB2C@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33957 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S964888AbWIKFwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 01:52:19 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FB2C@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-10 at 22:33 -0700, Michael Chan wrote:
> Benjamin Herrenschmidt wrote:
> 
> > I've done:
> > 
> > #define tw32_rx_mbox(reg, val)	do { wmb();
> tp->write32_rx_mbox(tp, reg, val); } while(0)
> > #define tw32_tx_mbox(reg, val)	do { wmb();
> tp->write32_tx_mbox(tp, reg, val); } while(0)
> > 
> 
> That should do it.
> 
> I think we need those tcpdump after all.  Can you send it to me?

Looks like adding a sync to writel does fix it though... I'm trying to
figure out which specific writel in the driver makes a difference. I'll
then look into slicing those tcpdumps.

Ben.


