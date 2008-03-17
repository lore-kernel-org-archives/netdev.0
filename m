From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10273] New: Sun GEM (PCI) - network device
 doesn't work
Date: Mon, 17 Mar 2008 14:36:24 -0700
Message-ID: <20080317143624.da313311.akpm@linux-foundation.org>
References: <bug-10273-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, seraph@xs4all.nl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44578 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752944AbYCQVg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 17:36:27 -0400
In-Reply-To: <bug-10273-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Mar 2008 14:25:50 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10273
> 
>            Summary: Sun GEM (PCI) - network device doesn't work
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: seraph@xs4all.nl
> 
> 
> Latest working kernel version: 2.6.22.9
> Earliest failing kernel version: 2.6.23

A regression in 2.6.23.

> Distribution: Gentoo
> Hardware Environment: Sparc64 (Sun Blade 100)
> Software Environment:
> Problem Description: 
> 
> I have two nearly identical Sun Blade 100 systems. Up to and including kernel
> version 2.6.22.9, both were working fine. However, with the 2.6.23- and 2.6.24-
> series I cannot get the Sun GEM network device on one of the two Blades to
> work. The other one strangely does not have this problem at all.
> 
> The network device detects fine and the sungem module loads without problems.
> Mii-diag reports that a 100FDX connection exists and there is link beat.
> However, packets are neither being sent nor received, all counters in ifconfig
> remain at zero.
> 
> Attempts to use the network eventually result in the following message in
> dmesg:
> 
> eth0: Sun GEM (PCI) 10/100/1000BaseT Ethernet 00:03:ba:08:61:7c
> eth0: Found Generic MII PHY
> eth0: Link is up at 100 Mbps, full-duplex.
> eth0: Link is up at 100 Mbps, full-duplex.
> eth0: Pause is disabled
> NETDEV WATCHDOG: eth0: transmit timed out
> eth0: transmit timed out, resetting
> eth0: TX_STATE[003ffc05:00000001:0000001f]
> eth0: RX_STATE[0100c805:00000001:00000021]
> eth0: Link is up at 100 Mbps, full-duplex.
> eth0: Pause is disabled
> 
> 
> The difference between the non-working system and the working one are as
> follows:
> - The non-working system has more memory (1G opposed to 512M)
> - A dual SCSI controller is present in this system. Connected to it are two
> external 72G disks and an Exabyte Mammoth tapedrive.
> 01:02.0 SCSI storage controller: LSI Logic / Symbios Logic 53c875 (rev 14)
> 01:02.1 SCSI storage controller: LSI Logic / Symbios Logic 53c875 (rev 14)
> - The following kernel modules are loaded on this system and not on the working
> one: sym53c8xx, sd_mod, st, nfsd, md_mod and raid1 plus of course their
> respective dependencies.
> 
> The problem is exactly the same with both Gentoo-patched kernels and vanilla
> kernels, that's why I am reporting it here.
> 
> 
> Steps to reproduce:
> 
> Just boot an affected kernel and try to use eth0 in any way.
> 

