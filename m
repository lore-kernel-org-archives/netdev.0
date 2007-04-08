From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: APIC error on 32-bit kernel
Date: Sun, 8 Apr 2007 13:38:22 -0500
Message-ID: <20070408133822.3868e6ff@osprey.hogchain.net>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf22aec.mail.bellsouth.net ([205.152.59.70]:58580 "EHLO
	imf22aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751744AbXDHSiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 14:38:25 -0400
In-Reply-To: <20070323200817.1f3e39b9@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Adding linux-kernel to the cc list, hoping for wider exposure.]

On Fri, 23 Mar 2007 20:08:17 -0500
Jay Cliburn <jacliburn@bellsouth.net> wrote:

> We're trying to track down the source of a problem that occurs
> whenever the atl1 network driver is activated on a 32-bit 2.6.21-rc4

and -rc5, -rc6, 2.6.20.x, 2.6.19.3, and probably others.

> We can load the driver just fine, but whenever we activate the
> network, we see APIC errors (a sample of them are shown here,
> captured from a serial console):
> 
> [root@hawk ~]# echo 8 > /proc/sys/kernel/printk
> [root@hawk ~]# [   93.942012] process `sysctl' is using deprecated
> sysctl (sysc.
> [   94.396609] atl1: eth0 link is up 1000 Mbps full duplex
> [   94.498887] APIC error on CPU0: 00(08)
> [   94.498534] APIC error on CPU1: 00(08)
> [   94.550079] APIC error on CPU0: 08(08)
> [   94.549725] APIC error on CPU1: 08(08)
> [   94.600915] APIC error on CPU1: 08(08)
> [   94.601276] APIC error on CPU0: 08(08)
> [   94.652108] APIC error on CPU1: 08(08)
> [   94.652470] APIC error on CPU0: 08(08)
> [   94.703659] APIC error on CPU0: 08(08)
> [   94.703305] APIC error on CPU1: 08(08)
> [   94.754852] APIC error on CPU0: 08(40)
> [   94.806045] APIC error on CPU0: 40(08)
> [   94.805692] APIC error on CPU1: 08(08)
> [   94.857238] APIC error on CPU0: 08(08)
> [   94.856884] APIC error on CPU1: 08(08)
> [   94.908432] APIC error on CPU0: 08(08)
> [   94.908078] APIC error on CPU1: 08(08)
> [snip, more of the same]
> [   98.901156] APIC error on CPU1: 08(08)
> [   98.952702] APIC error on CPU0: 08(08)
> [   98.952349] APIC error on CPU1: 08(08)
> [   99.003895] APIC error on CPU0: 08(08)
> [   99.003542] APIC error on CPU1: 08(08)
> 
> The machine hangs for about 5-10 seconds, then spontaneously reboots
> without further console output.

I can prompt an oops by pinging my router while the apic errors are
scrolling by.

> 
> This is an Asus M2V (Via K8T890) motherboard.
> 
> The problem does not occur on a 32-bit kernel if we boot with
> pci=nomsi, and it doesn't occur at all on a 64-bit kernel on the same
> motherboard.
> 
> We also do not see this problem on Intel-based motherboards, with
> either 32- or 64-bit kernels.

A full raft of documentation -- including acpidump and
linux-firmware-kit output, console capture, kernel config, lspci -vvxxx
(with apic=debug boot option), dmesg, and /proc/interrupts -- is
available at http://www.hogchain.net/m2v/apic-problem/

If this is a motherboard problem, that's fine; I'd just like to know
the details so I tell users something more than "it's a motherboard
problem."

Thanks,
Jay
