From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99191] New: ARP monitoring with bonding module uses
 interface alias for ARP request
Date: Wed, 10 Jun 2015 17:41:21 -0700
Message-ID: <20150610174121.39f9d19d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35594 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbFKAlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 20:41:21 -0400
Received: by qkhq76 with SMTP id q76so33351949qkh.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 17:41:20 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id 138sm4877215qhx.18.2015.06.10.17.41.19
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 17:41:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 29 May 2015 17:59:33 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99191] New: ARP monitoring with bonding module uses interface alias for ARP request


https://bugzilla.kernel.org/show_bug.cgi?id=99191

            Bug ID: 99191
           Summary: ARP monitoring with bonding module uses interface
                    alias for ARP request
           Product: Networking
           Version: 2.5
    Kernel Version: All
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: lessani@gmail.com
        Regression: No

When using arp_ip_target combined with arp_validate to verify the connectivity
status of a bond, the wrong IP address is used as the source of the request if
multiple IP aliases are assigned to the bond0.

Example 1.

bond0   - 10.0.0.5/24 (WAN)
bond0:1 - 10.0.1.5/24 (LAN)
arp_validate - all
arp_ip_target - 10.0.0.1

Expected result: ARP, Request who-has 10.0.0.1 tell 10.0.0.5

Actual result:   ARP, Request who-has 10.0.0.1 tell 10.0.1.5

Issue:           The Layer 3 switch responsible for replying to the ARP request
does not have the local interface of 10.0.1.5 configured, so the ARP request
goes unanswered.

-

My expectation is that the bonding driver would use the primary IP on the bond0
interface, not a secondary IP. The solution being to be able to specify which
IP the ARP should originate from in a scenario where bondX has multiple IPs
assigned.

Mangling the packet in/out using arptables does not achieve the desired effect.

-- 
You are receiving this mail because:
You are the assignee for the bug.
