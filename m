From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: strange sky disable/enable in the kernel log
Date: Mon, 25 Jun 2007 10:01:26 +0200
Message-ID: <20070625080126.GA26566@dose.home.local>
References: <20070622055342.GA11876@dose.home.local> <20070624231120.4c04a2ee@freepuppy.localdomain.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:53194 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbXFYIB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 04:01:27 -0400
Received: from dose.home.local (port-212-202-201-164.dynamic.qsc.de [212.202.201.164])
	by eazy.amigager.de (Postfix) with ESMTP id EA1B725C004
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 10:01:25 +0200 (CEST)
Received: from scorpion by dose.home.local with local (Exim 4.67)
	(envelope-from <tino.keitel@tikei.de>)
	id 1I2jVm-00074J-I5
	for netdev@vger.kernel.org; Mon, 25 Jun 2007 10:01:26 +0200
Content-Disposition: inline
In-Reply-To: <20070624231120.4c04a2ee@freepuppy.localdomain.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 24, 2007 at 23:11:20 -0700, Stephen Hemminger wrote:
> On Fri, 22 Jun 2007 07:53:42 +0200
> Tino Keitel <tino.keitel@tikei.de> wrote:
> 
> > Hi,
> > 
> > I just found this in the kernel log:
> > 
> > 2007-06-22_05:47:50.69894 kern.info: sky2 eth0: disabling interface
> > 2007-06-22_05:47:50.72039 kern.info: sky2 eth0: enabling interface
> > 2007-06-22_05:47:50.72240 kern.info: sky2 eth0: ram buffer 48K
> > 2007-06-22_05:47:52.40903 kern.info: sky2 eth0: Link is up at 100 Mbps,
> > full duplex, flow control both
> > 
> > What could be the cause for this? I use kernel 2.6.22-rc5 with this
> > hardware:
> > 
> > sky2 0000:01:00.0: v1.14 addr 0x90200000 irq 17 Yukon-EC (0xb6) rev 2
> > 
> > 01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
> > PCI-E Gigabit Ethernet Controller (rev 22)
> > 
> > Regards,
> > Tino
> 
> Some  script is calling the device stop (down) call. 
> 	ifconfig eth0 down
> 	ip link set eth0 down

I have a network watchdog script, that should only run after suspend,
as the sky2 driver sometimes hangs after resume. It tries to do a DNS
lookup and re-initializes the interface (ifdown, rmmod, modprobe, ifup)
if the lookup failed. But no activity here at that time:

2007-06-22_04:47:54.31644 Server:               10.100.1.254
2007-06-22_04:47:54.32896 Address:      10.100.1.254#53
2007-06-22_04:47:54.32897
2007-06-22_04:47:54.32898 Name: mguard.home.local
2007-06-22_04:47:54.32899 Address: 10.100.1.253
2007-06-22_04:47:54.32899
2007-06-22_08:47:04.15808 Server:               10.100.1.254
2007-06-22_08:47:04.17365 Address:      10.100.1.254#53
2007-06-22_08:47:04.17366
2007-06-22_08:47:04.17367 Name: mguard.home.local
2007-06-22_08:47:04.17368 Address: 10.100.1.253
2007-06-22_08:47:04.17369

> another possibility is suspend/resume.

A resume happened at 4:47:

2007-06-22_04:47:31.51073 kern.debug: Back to C!

So the above disabling interface/enabling interface was in the middle
of normal operation.

Regards,
Tino
