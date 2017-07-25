From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196469] New: UDPv4+UDPv6 receive silently fails after
 heavy UDP load
Date: Tue, 25 Jul 2017 11:40:25 -0700
Message-ID: <20170725114025.14ab6616@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34035 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdGYSk1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 14:40:27 -0400
Received: by mail-pf0-f180.google.com with SMTP id q85so61590301pfq.1
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 11:40:27 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id e6sm12416653pgf.56.2017.07.25.11.40.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Jul 2017 11:40:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 24 Jul 2017 20:52:01 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196469] New: UDPv4+UDPv6 receive silently fails after heavy UDP load


https://bugzilla.kernel.org/show_bug.cgi?id=196469

            Bug ID: 196469
           Summary: UDPv4+UDPv6 receive silently fails after heavy UDP
                    load
           Product: Networking
           Version: 2.5
    Kernel Version: 4.12.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: CFSworks@gmail.com
        Regression: No

I have a system that's performing heavy SNMP monitoring on various devices over
IPv6. After upgrading it from 4.11.5 to 4.12.2 last week, I noticed this
weekend that all UDP packets received by the system were being silently
dropped.

The problem happened this weekend, after the system had been running for about
2 days with no issue, and without any human intervention at the time (i.e. it
broke on its own - no configuration changes were made). I verified UDP replies
were coming in via tcpdump, and checked netfilter and conntrack to make sure
nothing was blocking it (indeed netfilter/conntrack is able to see the traffic,
indicating the problem is deeper in the network stack). There is no relevant or
even unusual output whatsoever in dmesg.

This affects ALL received UDPv4/UDPv6 packets, even traffic on a loopback
interface: opening a pair of Python sessions and trying to send UDP traffic
back and forth on 127.0.0.1 results in the traffic getting dropped as well.
ICMP and TCP are unaffected.

My gut says it's a race condition somewhere in the UDP receive queue(s). What
puzzles me is why heavy UDPv6 load caused the kernel to shut out all UDPv4
traffic too.

-- 
You are receiving this mail because:
You are the assignee for the bug.
