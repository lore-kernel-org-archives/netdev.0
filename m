From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: FEC driver hangs hardware on i.MX6SX
Date: Mon, 21 Jul 2014 02:13:39 +0000
Message-ID: <06acadb1ae284d39915d32a7adfb052f@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20140720025732.GF8537@dragon> <20140720062048.GB5686@netboy>
 <20140721015915.GG8537@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <Shawn.Guo@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:52878
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750837AbaGUCNo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 22:13:44 -0400
In-Reply-To: <20140721015915.GG8537@dragon>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@freescale.com> Data: Monday, July 21, 2014 9:59 AM
>To: Richard Cochran
>Cc: Duan Fugang-B38611; linux-arm-kernel@lists.infradead.org;
>netdev@vger.kernel.org; Li Frank-B20596; David S. Miller
>Subject: Re: FEC driver hangs hardware on i.MX6SX
>
>On Sun, Jul 20, 2014 at 08:20:49AM +0200, Richard Cochran wrote:
>> On Sun, Jul 20, 2014 at 10:57:33AM +0800, Shawn Guo wrote:
>> >
>> > I think the cause is that PTP is still accessing registers after FEC
>> > driver calls fec_enet_clk_enable(ndev, false) to disable FEC clocks.
>> > Can you please try to provide a fix for this regression soon?
>>
>> What do you mean by, "PTP is still accessing registers"?
>>
>> The only access to any register is through the driver, and the driver
>> can and should make sure all register accesses are safe.
>
>Sorry for being vague, Richard.  I meant PTP driver is still accessing
>registers.
>
>With Fugang's clock management patch, FEC clocks will be disabled to save
>power after FEC gets probed.  But at that point, fec_ptp driver already
>launches a timer, which will trigger the read on FEC ATIME register once
>per second.
>
>Shawn
	
Yes, why does it cause at imx6sx platform ?
Because imx5x, imx6q/dl/sl  enet register access don't cause system hang when clock is disab led, just return one error value that is zero.
But for imx6sx, if there disable enet ipg clock, and access register, which cause system hang.

For clock management patch itself, there have no any problem.  
Just ptp driver has one issue which think clock is always on.

I  submit one patch to fix the ptp issue.

Thanks,
Andy
