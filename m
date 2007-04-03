From: Len Brown <lenb@kernel.org>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 01:20:29 -0400
Message-ID: <200704030120.29619.lenb@kernel.org>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Christian Kujau <evil@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:54987 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbXDCFVs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 01:21:48 -0400
In-Reply-To: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 02 April 2007 15:41, Christian Kujau wrote:
> 
> Hi there,
> 
> we have serious problems with 2 of our servers: both shiny new amd64 
> dual core, with both 2GB RAM, 32bit kernel+userland (Debian/testing).
> Both servers have 2 NICs, RTL8139 (eth0, irq10) and RTL8169s
> (eth1, irq11).
> 
> Both boxes are running fine but after "a while" they lock up and 
> eventually restart all of a sudden. The last messages in the logfile 
> are:
> 
> 14:15:11 db2 kernel: NETDEV WATCHDOG: eth0: transmit timed out
> 14:15:14 db2 kernel: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> 
> Then the box reboots, nothing else in the log.
> 
> As the servers have been set up recently, we only know that it happend 
> with Debian's 2.6.17-? kernel. When we upgraded the installation, we 
> went to 2.6.18-4-k7 and the problem persistent. We're using now vanilla 
> 2.6.20.4 and while the problem persists, it takes longer to lockup (~20h 
> as opposed to 4-5h). While this is a good thing for us, it's now harder
> to reproduce (we have to wait longer).
> 
> Searching the archives turned up quite a few results but no real fix and 
> lots of old postings too. We then disabled ACPI completely and booted 
> with 'noapic'. Now both boxes are running for > 20h and we're curious 
> how long they make it. However, booting with 'noapic' slowed down both 
> servers *a lot*.

Which increased stability, disabling ACPI, or disabling the IOAPIC?
Your box has MPS, so you should be able to use the IOAPIC in either mode.
Note that you can do these both independently at boot-time with "acpi=off"
and "noapic", respectively.
eg. 4 combos
1. <default - no boot params>
2. noapic
3. acpi=off
4. acpi=off noapic

you started with #1, and are running hard-coded #4 now, but skipped #2 and #3

cheers,
-Len

> >From /proc/interrupts we can see that only CPU0 (core 0) is handling 
> interrupts while CPU1 does not. We compiled with CONFIG_IRQBALANCE=n so 
> that irqbalance(1) would work - but to no avail.
> 
> Please see http://nerdbynature.de/bits/2.6.20.4/ for details for both 
> hosts and feel free to ask for more details. Although both boxes are in 
> production we'll be happy test more bootoptions/patches and the like.
> 
> TIA,
> Christian.
