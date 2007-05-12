From: Len Brown <lenb@kernel.org>
Subject: Re: APIC error on 32-bit kernel
Date: Fri, 11 May 2007 23:28:58 -0400
Message-ID: <200705112328.58927.lenb@kernel.org>
References: <20070323200817.1f3e39b9@osprey.hogchain.net> <20070408133822.3868e6ff@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:44818 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667AbXELDaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 23:30:18 -0400
In-Reply-To: <20070408133822.3868e6ff@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > We're trying to track down the source of a problem that occurs
> > whenever the atl1 network driver is activated on a 32-bit 2.6.21-rc4
> 
> and -rc5, -rc6, 2.6.20.x, 2.6.19.3, and probably others.
> 
> > We can load the driver just fine, but whenever we activate the
> > network, we see APIC errors (a sample of them are shown here,
> > captured from a serial console):
> > 
> > [root@hawk ~]# echo 8 > /proc/sys/kernel/printk
> > [root@hawk ~]# [   93.942012] process `sysctl' is using deprecated
> > sysctl (sysc.
> > [   94.396609] atl1: eth0 link is up 1000 Mbps full duplex
> > [   94.498887] APIC error on CPU0: 00(08)
> > [   94.498534] APIC error on CPU1: 00(08)
> > [   94.550079] APIC error on CPU0: 08(08)
> > [   94.549725] APIC error on CPU1: 08(08)
> > [   94.600915] APIC error on CPU1: 08(08)
> > [   94.601276] APIC error on CPU0: 08(08)
> > [   94.652108] APIC error on CPU1: 08(08)
> > [   94.652470] APIC error on CPU0: 08(08)
> > [   94.703659] APIC error on CPU0: 08(08)
> > [   94.703305] APIC error on CPU1: 08(08)
> > [   94.754852] APIC error on CPU0: 08(40)
> > [   94.806045] APIC error on CPU0: 40(08)

        /* Here is what the APIC error bits mean:
           0: Send CS error
           1: Receive CS error
           2: Send accept error
           3: Receive accept error
           4: Reserved
           5: Send illegal vector
           6: Received illegal vector
           7: Illegal register address
        */

So the 40 means the APIC got an illegal vector.
Certainly this is consistent with the fact that
the errors start when a specific device is being
used.  I assume that device is using MSI?
Curious that it is different in 32-bit and 64-bit mode.



> > [   94.805692] APIC error on CPU1: 08(08)
> > [   94.857238] APIC error on CPU0: 08(08)
> > [   94.856884] APIC error on CPU1: 08(08)
> > [   94.908432] APIC error on CPU0: 08(08)
> > [   94.908078] APIC error on CPU1: 08(08)
> > [snip, more of the same]
> > [   98.901156] APIC error on CPU1: 08(08)
> > [   98.952702] APIC error on CPU0: 08(08)
> > [   98.952349] APIC error on CPU1: 08(08)
> > [   99.003895] APIC error on CPU0: 08(08)
> > [   99.003542] APIC error on CPU1: 08(08)
> > 
> > The machine hangs for about 5-10 seconds, then spontaneously reboots
> > without further console output.
> 
> I can prompt an oops by pinging my router while the apic errors are
> scrolling by.
> 
> > 
> > This is an Asus M2V (Via K8T890) motherboard.
> > 
> > The problem does not occur on a 32-bit kernel if we boot with
> > pci=nomsi, and it doesn't occur at all on a 64-bit kernel on the same
> > motherboard.

pci=nomsi, works, okay...


> > We also do not see this problem on Intel-based motherboards, with
> > either 32- or 64-bit kernels.
> 
> A full raft of documentation -- including acpidump and
> linux-firmware-kit output, console capture, kernel config, lspci -vvxxx
> (with apic=debug boot option), dmesg, and /proc/interrupts -- is
> available at http://www.hogchain.net/m2v/apic-problem/


[06Dh 109  2]      Boot Architecture Flags : 0003

for what it is worth, the bit in ACPI that is used to
disable MSI support is not set -- so as  far as the BIOS
is concerned, this system should support MSI.

Is it an add-in card, or lan-on-motherboard?

-Len
