From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Thu, 2 Mar 2017 10:32:19 -0800
Message-ID: <20170302103219.74b675c5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34960 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751461AbdCBSkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 13:40:18 -0500
Received: by mail-pg0-f49.google.com with SMTP id b129so34901059pgc.2
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 10:39:27 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id a8sm18486948pfa.30.2017.03.02.10.32.20
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 02 Mar 2017 10:32:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 01 Mar 2017 21:08:01 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194749] New: kernel bonding does not work in a network nameservice in versions above 3.10.0-229.20.1


https://bugzilla.kernel.org/show_bug.cgi?id=194749

            Bug ID: 194749
           Summary: kernel bonding does not work in a network nameservice
                    in versions above 3.10.0-229.20.1
           Product: Networking
           Version: 2.5
    Kernel Version: > 3.10.0-229.20.1
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: dan@polter.net
        Regression: No

bond interface is being used in active/standby mode with two physical NICs
inside a network nameservice to provide switchpath redundancy.

netns is instantiated post-boot with the following:

ip netns add vntp
ip link set p4p1 netns vntp
ip link set p4p2 netns vntp
ip link set bond0 netns vntp
ip netns exec vntp ip link set lo up
ip netns exec vntp ip link set p4p1 up
ip netns exec vntp ip link set p4p2 up
ip netns exec vntp ip link set bond0 up
ip netns exec vntp ifenslave bond0 p4p1 p4p2

This works as one would expect in kernel versions up to 3.10.0-229.20.1 (CentOS
7 packages). At the next patchlevel and all subsequent versions released by the
packager, the following appears in system logs and the bond0 instantiation
fails:

Mar  1 19:33:42 fed1ntpi01 rc.local: Cannot find device "bond0"
Mar  1 19:33:42 fed1ntpi01 rc.local: Master 'bond0': Error: handshake with
driver failed. Aborting
Mar  1 19:33:42 fed1ntpi01 rc.local: Cannot find device "bond0"
Mar  1 19:33:42 fed1ntpi01 rc.local: Cannot find device "bond0"

-- 
You are receiving this mail because:
You are the assignee for the bug.
