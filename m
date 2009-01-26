From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fwd: [Bug 10799] sky2 general protection fault
Date: Sun, 25 Jan 2009 19:23:48 -0800
Message-ID: <20090125192348.649d1414@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johnpaulmorrison@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33015 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751240AbZAZDY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 22:24:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It's a good cable and switch port - it was used on a different machine with no
> issues. According to the switch it's negotiated to auto/100. The hardware is
> also working OK with the sk98lin driver. There may also be some extra log
> messages because of me trying to remotely recover the system by resetting the
> switch port. 
> 
> What debugging is needed to help here? I need to keep this system up, and so
> far sk98lin is working, but I could run sky2 again for a while and use another
> nic to remotely reset the interface.
> 
> 
> I've attached syslogs from the dates I was running sky2
> 
> Jan 16 08:41:22 kernel: [    0.000000] Linux version 2.6.28-4-server
> (buildd@vernadsky) (gcc version 4.3.3 20090111 (prerelease) (Ubuntu
> 4.3.2-2ubuntu11) ) #10-Ubuntu SMP Mon Jan 12 20:35:38 UTC 2009 (Ubuntu
> 2.6.28-4.10-server)
> Jan 16 08:41:34 kernel: [    6.398381] sky2 driver version 1.22
> Jan 16 08:41:34 kernel: [    6.398407] sky2 0000:01:00.0: PCI INT A -> GSI 17
> (level, low) -> IRQ 17
> Jan 16 08:41:34 kernel: [    6.398443] sky2 0000:01:00.0: Yukon-2 EC Ultra chip
> revision 3
> Jan 16 08:41:34 kernel: [    6.430561] sky2 0000:01:00.0: Marvell Yukon 88E8056
> Gigabit Ethernet Controller
> Jan 16 08:41:34 kernel: [    6.431102] sky2 eth0: addr 00:1b:fc:a0:a6:cb
> Jan 16 08:41:34 kernel: [   15.547168] sky2 eth0: enabling interface
> Jan 16 08:41:34 kernel: [   15.550225] ADDRCONF(NETDEV_UP): eth0: link is not
> ready
> Jan 16 08:41:34 kernel: [   18.444818] sky2 eth0: Link is up at 100 Mbps, full
> duplex, flow control rx
> Jan 16 08:41:34 kernel: [   18.444952] ADDRCONF(NETDEV_CHANGE): eth0: link
> becomes ready
> Jan 16 08:41:34 kernel: [   18.510127] sky2 eth0: Link is down.
> Jan 16 08:41:34 kernel: [   21.399482] sky2 eth0: Link is up at 100 Mbps, full
> duplex, flow control rx
> Jan 16 09:02:18 kernel: [    3.921621] sky2 0000:01:00.0: PCI INT A -> GSI 17
> (level, low) -> IRQ 17
> Jan 16 09:02:18 kernel: [    3.921657] sky2 0000:01:00.0: v1.22 addr 0xfeafc000
> irq 17 Yukon-2 EC Ultra rev 3
> Jan 16 09:02:18 kernel: [    3.922000] sky2 eth0: addr 00:1b:fc:a0:a6:cb
> Jan 16 09:03:39 kernel: [    3.910116] sky2 0000:01:00.0: v1.13 addr 0xfeafc000
> irq 16 Yukon-EC Ultra (0xb4) rev 3
> Jan 16 09:03:39 kernel: [    3.910190] sky2 eth0: addr 00:1b:fc:a0:a6:cb
> Jan 16 09:03:39 kernel: [   15.345272] sky2 eth0: enabling interface
> Jan 16 09:03:39 kernel: [   15.394455] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.395482] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.396508] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.397534] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.398560] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.399582] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.400606] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.401630] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.402653] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.403676] sky2 eth0: phy write timeout
> Jan 16 09:03:39 kernel: [   15.403778] sky2 eth0: ram buffer 1020K
> Jan 16 09:03:39 kernel: [   15.405023] ADDRCONF(NETDEV_UP): eth0: link is not
> ready
> Jan 16 09:32:37 kernel: [    3.060427] sky2 0000:01:00.0: v1.21 addr 0xfeafc000
> irq 17 Yukon-EC Ultra (0xb4) rev 3

Taking this out of bugzilla and onto netdev where it belongs

Why is the link bouncing so much. Does your switch not support autoneg?

If you see phy write timeouts, there are lower level problems. Check that the
firmware is up to date. You need to get that from the motherboard mfg, there isn't
a generic version. The firmware does a bunch of register settings that are design
dependent, so I wouldn't just take it from any other motherboard.
