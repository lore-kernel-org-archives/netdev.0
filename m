From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196445] New: Increasing RX packet drop issue with VT6130
 Ethernet (VIA Velocity) and an VIA EPIA-3002 board
Date: Mon, 24 Jul 2017 08:12:37 -0700
Message-ID: <20170724081237.3155f05d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34859 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753689AbdGXPMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:12:44 -0400
Received: by mail-pg0-f51.google.com with SMTP id v190so58417782pgv.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 08:12:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 22 Jul 2017 21:38:01 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196445] New: Increasing RX packet drop issue with VT6130 Ethernet (VIA Velocity) and an VIA EPIA-3002 board


https://bugzilla.kernel.org/show_bug.cgi?id=196445

            Bug ID: 196445
           Summary: Increasing RX packet drop issue with VT6130 Ethernet
                    (VIA Velocity) and an VIA EPIA-3002 board
           Product: Networking
           Version: 2.5
    Kernel Version: 4.11.10-300.fc26.x86_64 (prior also concerned)
          Hardware: x86-64
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: patrick@reebs.org
        Regression: No

After I upgraded a Fedora (FC20) router to Fedora 26, I noticed issues in the
networking.

The transfer speed for files sent to the box via Samba or vsftpd was horribly
slow at about 5 to 10mb/s while the other direction works perfectly.

ifconfig shows a large amount of packet drops (RX dropped), both on the
Internet adapter enp1s0 as on the network connected adapter enp2s0 hence packet
routing to the network when surfing is enough to cause packet drops.

To rule out a firewall issue, I set all default rules to allow and flushed the
tables. This had no effect. I also changed the ACPI level in BIOS, but that did
not have an impact either.

Because I had a couple of system backups (done trough dd if=/dev/...) I
restored the oldest backup I had, which was running Fedora 20 Kernel
3.17.4-200.fc20.x86_64.

There I saw that although there where also packets dropped, the amount of
dropped packets was much lower (like 10 or more times) and the speed sending
files to the box was much faster (20 to 30 Mb/s), why I eventually didn't
notice. The latest fedora 20 backup before installing FC26 was
3.19.8-100.fc20.x86_64 and behaved almost like the 3.17 kernel.

One interesting thing I noticed is that when I run tcpdump, then the amount of
doped RX packets drops significantly, sometime to no drops and the speed
measured when moving files to the box goes from 5 to 10 mb/s to about 20 mb/s.
Eventually showing an issue with the RX queue management?!

Tests I have done so far:
 - Disabled one of the two adapters
 - Directly connected to the box without switch
 - Changed the Cat6a cable and directly connected
 - Started/Stopped/Disabled other services (VPN, named, dhcp, ...)
 - Tested the write speed to the share drive directly on the box (was 110mb/s
so no bottleneck)
 - Ping: no losses until the network load rises, then some ICMPs are lost.
 - Checked link speed and duplex mode (all of which are 1000TX and Full duplex,
so OK.

none of which gave any noticeable results.

Running dropwatch under network load I get a lot of "drops at net_tx_action+0"
which points to dev.c..

By the way, VIA advertises the Network chip on their web page as VT6130G for
the EPIA-3002 board. Not sure if it is the same as the usually found VT6130
chip.

-- 
You are receiving this mail because:
You are the assignee for the bug.
