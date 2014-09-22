From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84951] New: 8021q: kernel doesn't take into account
 ethernet header bytes for received packets
Date: Mon, 22 Sep 2014 09:01:34 -0700
Message-ID: <20140922090134.3a114531@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35317 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754443AbaIVQBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 12:01:42 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so5335202pad.35
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 09:01:41 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id fl15sm9719792pdb.92.2014.09.22.09.01.40
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 09:01:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am inclined to think this is something that is just an incorrect
user expectation.

Begin forwarded message:

Date: Sun, 21 Sep 2014 11:47:22 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84951] New: 8021q: kernel doesn't take into account ethernet header bytes for received packets


https://bugzilla.kernel.org/show_bug.cgi?id=84951

            Bug ID: 84951
           Summary: 8021q: kernel doesn't take into account ethernet
                    header bytes for received packets
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.1
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: g.djavadyan@gmail.com
        Regression: No

Statistics exported by the kernel for received packets on 802.1q subinterfaces
don't consider Ethernet header bytes (dst MAC, src MAC, type). Statistics for
transmitted packets is not affected. The problem is more prominent on
high-speed links (>100Mb/s), as networking tools (nload, iftop, ...) display
lower bandwidth utilization (>5Mb/s difference) than a report from neighboring
routing device (FreeBSD, Cisco). Also, someone monitoring Linux router
interfaces will find that the router generates more information than it
receives.

Tested on CentOS kernel 2.6.32-431.29.2.el6.x86_64 and vanilla 3.16.1 with
drivers: bnx2, atl1c and igb.

How to reproduce:

1. Create dot1q subinterfaces on two boxes (vconfig add eth0 4040).
2. Assign IP addresses to subinterfaces.
3. Check the connection using ping.
4. Check the output from ifconfig eth0.4040 or 'cat
/sys/class/net/eth0.4040/statistics/rx_{packets,bytes}'.
5. Issue standard 56 byte payload ping using 'ping -c 1 neighboring_ip'.
6. Recheck statistics using step 4.

Expected results:

Received packets value should increase by 1 and received bytes value should
increase by 98.

dst MAC - 6
src MAC - 6
ethertype - 2
IP header - 20
ICMP header - 8
ICMP Payload - 56
Total: 98 bytes.


Actual results:

Received packets value increases by 1 and received bytes value increases by 84
bytes.

-- 
You are receiving this mail because:
You are the assignee for the bug.
