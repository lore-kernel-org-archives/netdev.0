From: Adrian Bunk <bunk@kernel.org>
Subject: [Bug 10790] New: driver "sunhme" experiences corrupt packets if
	machine has more than 2GB of memory (fwd)
Date: Sun, 25 May 2008 20:30:08 +0300
Message-ID: <20080525173008.GE1791@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jeff Garzik <jeff@garzik.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:57718 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbYEYRcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 13:32:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, can you look at this bug (email answers to this email are fine)?


----- Forwarded message from bugme-daemon@bugzilla.kernel.org -----

Date: Sun, 25 May 2008 04:10:04 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: bunk@kernel.org
Subject: [Bug 10790] New: driver "sunhme" experiences corrupt packets if
	machine has more than 2GB of memory

http://bugzilla.kernel.org/show_bug.cgi?id=10790

           Summary: driver "sunhme" experiences corrupt packets if machine
                    has more than 2GB of memory
           Product: Drivers
           Version: 2.5
     KernelVersion: 2.6.22.17-0.1
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Network
        AssignedTo: jgarzik@pobox.com
        ReportedBy: f0h3a-kernel@yahoo.com
                CC: kkeil@suse.de


Latest working kernel version: unknown
Earliest failing kernel version: unknown
Distribution: OpenSUSE 10.3 (also tested on vanilla kernel) - filed on Novell
bugzilla at https://bugzilla.novell.com/show_bug.cgi?id=376831


Hardware Environment:
System 1: Q6600 cpu, 4GB mem, Asus P5N32-E SLI Plus, Sun QFE card
System 2: Q6600 cpu, 4GB mem, MSI P35 NEO-F (P35), Sun QFE card

Software Environment: OpenSUSE 10.3, both SUSE & vanilla kernels

Problem Description:

Network interfaces on the QFE card experience corrupted packets when the
machine has more than 2GB of memory. The NIC can successfully obtain a DHCP
address from a server, but attempts to ping or ssh to the address give
unexpected results


hazard@mustang:~/hme-debug> ping 192.168.2.90
PING 192.168.2.90 (192.168.2.90) 56(84) bytes of data.
64 bytes from 192.168.2.90: icmp_seq=1 ttl=64 time=2.20 ms
wrong data byte #54 should be 0x36 but was 0xba
#16     10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27
28 29 2a 2b 2c 2d 2e 2f 
#48     30 31 32 33 34 35 ba cc 
64 bytes from 192.168.2.90: icmp_seq=2 ttl=64 time=0.223 ms
wrong data byte #54 should be 0x36 but was 0x64
#16     10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27
28 29 2a 2b 2c 2d 2e 2f 
#48     30 31 32 33 34 35 64 d8 


hazard@mustang:~/hme-debug> ssh 192.168.2.90
Received disconnect from 192.168.2.90: 2: Corrupted MAC on input.
hazard@mustang:~/hme-debug> ssh 192.168.2.90
Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.
hazard@mustang:~/hme-debug> ssh 192.168.2.90
Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.
hazard@mustang:~/hme-debug> ssh 192.168.2.90
Received disconnect from 192.168.2.90: 2: Bad packet length 1869967922.


Steps to reproduce:

Plumb an interface on a Sun QFE card in a machine with > 2GB memory. Ping or
ssh to the IP of the interface.


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.

----- End forwarded message -----

