From: Craig Small <csmall@enc.com.au>
Subject: Re: r8169 won't transmit with 3.12
Date: Sat, 25 Jan 2014 11:59:22 +1100
Message-ID: <20140125005922.GA17716@enc.com.au>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
 <20140122004119.GA28174@enc.com.au>
 <20140122233135.GA800@electric-eye.fr.zoreil.com>
 <20140123075708.GA9172@enc.com.au>
 <20140124002525.GA29384@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:57729 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084AbaAYA70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 19:59:26 -0500
Content-Disposition: inline
In-Reply-To: <20140124002525.GA29384@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 01:25:25AM +0100, Francois Romieu wrote:
> > [    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by O.E.M./970A-D3P, BIOS F3 05/24/2013
> (8168evl on a fairly recent motherboard, bios could be upgraded)
Done!
[    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by
O.E.M./970A-D3P, BIOS F5 08/06/2013

> Did you enable the iommu in the setup ? If not, please give it a try.
That caused some excitement...
I got a page of AMD-Vi Event logged IO_PAGE_FAULT device 02:00.0 domain
0016 messages.
And then it sat at "waiting for /dev to be fully populated"
The keyboard seemed dead at that point. I'm not sure of the exact
message and if it is important I can make it die again.

I had to turn that off to get anywhere. Then we were back where we
started.
[   97.797982] WARNING: CPU: 4 PID: 0 at /build/linux-xS3nxO/linux-3.12.6/net/sched/sch_generic.c:264 dev_watchdog+0x226/0x230()
[   97.797989] NETDEV WATCHDOG: eth6 (r8169): transmit queue 0 timed out

I've also at times rebuilt the r8169 module to add more printk lines.
I can tell you that each packet makes it to rtl8169_start_xmit and
returns NETDEV_TX_OK because the number of printk lines for my enter
and exit equal the number of tx dropped packets.

What you are seeing though is from the stock Debian kernel module. If
you have a test module code you want me to run, let me know.

 - Craig
-- 
Craig Small (@smallsees)   http://enc.com.au/       csmall at : enc.com.au
Debian GNU/Linux           http://www.debian.org/   csmall at : debian.org
GPG fingerprint:        5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5
