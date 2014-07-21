From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: FEC driver hangs hardware on i.MX6SX
Date: Mon, 21 Jul 2014 09:59:16 +0800
Message-ID: <20140721015915.GG8537@dragon>
References: <20140720025732.GF8537@dragon> <20140720062048.GB5686@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Fugang Duan <B38611@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.139] ([207.46.163.139]:33675 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751586AbaGUB7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 21:59:46 -0400
Content-Disposition: inline
In-Reply-To: <20140720062048.GB5686@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 20, 2014 at 08:20:49AM +0200, Richard Cochran wrote:
> On Sun, Jul 20, 2014 at 10:57:33AM +0800, Shawn Guo wrote:
> > 
> > I think the cause is that PTP is still accessing registers after FEC
> > driver calls fec_enet_clk_enable(ndev, false) to disable FEC clocks.
> > Can you please try to provide a fix for this regression soon?
> 
> What do you mean by, "PTP is still accessing registers"?
> 
> The only access to any register is through the driver, and the driver
> can and should make sure all register accesses are safe.

Sorry for being vague, Richard.  I meant PTP driver is still accessing
registers.

With Fugang's clock management patch, FEC clocks will be disabled to
save power after FEC gets probed.  But at that point, fec_ptp driver
already launches a timer, which will trigger the read on FEC ATIME
register once per second.

Shawn
