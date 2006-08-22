From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: b44 (Broadcom BCM4401 100Base-T) + NETCONSOLE + link up == lockup
Date: Tue, 22 Aug 2006 08:04:34 -0400
Message-ID: <20060822120428.GA10348@tuxdriver.com>
References: <20060822092024.GA1089@janus> <200608221136.58034.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>, netdev@vger.kernel.org,
	jmoyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:34308 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932183AbWHVMFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 08:05:19 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608221136.58034.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 11:36:57AM +0200, Michael Buesch wrote:
> On Tuesday 22 August 2006 11:20, Frank van Maarseveen wrote:
> > Noticed this on 2.6.17.8 and it is easily reproduced. When disconnecting
> > and connecting the network cable from a BCM4401 100Base-T NIC the usual
> > "link is down" and "link is up" messages show up unless netconsole
> > logging is enabled upon boot using (e.g.):
> > 
> > 	netconsole=@172.17.1.65/,514@172.17.1.64/00:12:3f:85:17:52
> > 
> > In that case the "link is up" message no longer makes it to the virtual
> > console/remote machine and the machine seems to lock up. alt-sysrq-p
> > doesn't show anything on the VC (caps- and numlock are dead too) but
> > alt-sysrq-b works provided it is not preceded by too many unprinted kernel
> > messages (so it seems). The link does go up according to the link state
> > LED and there is some activity (incoming packets only I suppose).
> > 
> > unplugging and plugging again doesn't help.
> > 
> > During boot the kernel says:
> > 
> > 	kernel: netconsole: device eth0 not up yet, forcing it
> > 	kernel: b44: eth0: Link is up at 100 Mbps, full duplex.
> > 	kernel: b44: eth0: Flow control is off for TX and off for RX.
> > 	kernel: netconsole: network logging started
> 
> I think this is not a b44 but a netconsole problem.
> I saw this behaviour with netconsole and sungem in the past, too.
> I simply decided to not remove the cable while using netconsole :P
> But that's not really a solution, hehe.

If I'm not mistaken, this is an issue with the netpoll stack not being
able to handle printk output if the netpoll output device is down.
I forget the details...anyone?

John
-- 
John W. Linville
linville@tuxdriver.com
