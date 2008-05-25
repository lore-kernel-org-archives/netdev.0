From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10790] New: driver "sunhme" experiences
 corrupt packets if machine has more than 2GB of memory
Date: Sun, 25 May 2008 11:45:48 -0700
Message-ID: <20080525114548.6ad40fd7.akpm@linux-foundation.org>
References: <bug-10790-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, f0h3a-kernel@yahoo.com,
	Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33513 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758528AbYEYSqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 14:46:23 -0400
In-Reply-To: <bug-10790-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 May 2008 04:10:04 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10790
> 
>            Summary: driver "sunhme" experiences corrupt packets if machine
>                     has more than 2GB of memory
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.22.17-0.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: f0h3a-kernel@yahoo.com
>                 CC: kkeil@suse.de
> 
> 
> Latest working kernel version: unknown
> Earliest failing kernel version: unknown
> Distribution: OpenSUSE 10.3 (also tested on vanilla kernel) - filed on Novell
> bugzilla at https://bugzilla.novell.com/show_bug.cgi?id=376831
> 
> 
> Hardware Environment:
> System 1: Q6600 cpu, 4GB mem, Asus P5N32-E SLI Plus, Sun QFE card
> System 2: Q6600 cpu, 4GB mem, MSI P35 NEO-F (P35), Sun QFE card
> 
> Software Environment: OpenSUSE 10.3, both SUSE & vanilla kernels
> 
> Problem Description:
> 
> Network interfaces on the QFE card experience corrupted packets when the
> machine has more than 2GB of memory. The NIC can successfully obtain a DHCP
> address from a server, but attempts to ping or ssh to the address give
> unexpected results
> 
> 
> hazard@mustang:~/hme-debug> ping 192.168.2.90
> PING 192.168.2.90 (192.168.2.90) 56(84) bytes of data.
> 64 bytes from 192.168.2.90: icmp_seq=1 ttl=64 time=2.20 ms
> wrong data byte #54 should be 0x36 but was 0xba
> #16     10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27
> 28 29 2a 2b 2c 2d 2e 2f 
> #48     30 31 32 33 34 35 ba cc 
> 64 bytes from 192.168.2.90: icmp_seq=2 ttl=64 time=0.223 ms
> wrong data byte #54 should be 0x36 but was 0x64
> #16     10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27
> 28 29 2a 2b 2c 2d 2e 2f 
> #48     30 31 32 33 34 35 64 d8 
> 
> 
> hazard@mustang:~/hme-debug> ssh 192.168.2.90
> Received disconnect from 192.168.2.90: 2: Corrupted MAC on input.
> hazard@mustang:~/hme-debug> ssh 192.168.2.90
> Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.
> hazard@mustang:~/hme-debug> ssh 192.168.2.90
> Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.
> hazard@mustang:~/hme-debug> ssh 192.168.2.90
> Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.
> 
> 
> Steps to reproduce:
> 
> Plumb an interface on a Sun QFE card in a machine with > 2GB memory. Ping or
> ssh to the IP of the interface.
> 

Note that this patch from Karsten:
https://bugzilla.novell.com/attachment.cgi?id=217968 did not work.

Stoopid question: if it fails at 2GB, should we try DMA_31BIT_MASK?
