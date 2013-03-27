From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 55861] New: PMTU discovery no longer works in Linux 3.6+
 with routers that do not send next hop MTU information
Date: Wed, 27 Mar 2013 08:31:27 -0700
Message-ID: <20130327083127.0740d793@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:60109 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab3C0Pbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:31:40 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so2633205pbb.38
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 08:31:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 27 Mar 2013 08:25:40 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 55861] New: PMTU discovery no longer works in Linux 3.6+ with routers that do not send next hop MTU information


https://bugzilla.kernel.org/show_bug.cgi?id=55861

           Summary: PMTU discovery no longer works in Linux 3.6+ with
                    routers that do not send next hop MTU information
           Product: Networking
           Version: 2.5
    Kernel Version: 3.6 onwards
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: _@maxb.eu
        Regression: Yes


After upgrading recently, I found that path MTU discovery no longer worked
correctly for accessing some devices on the other side of an IPsec tunnel.

Bisection revealed the problems started with 3.6 and are still present in
3.9-rc4 (latest available at time of reporting).

Some investigation into code changes leads me to the belief that Linux lost
support for handling ICMP destination unreachable fragmentation needed packets
for which the next hop MTU field is zero. This is an expected condition when
dealing with older routers, as RFC792 originally defined ICMP destination
unreachable fragmentation needed without a next hop MTU field, and it was later
added in bytes previously allocated as unused.

The particular router in my case generating such packets is a machine running
OpenBSD 4.6.

A commit that appears to be of particular interest in this bug is
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=46517008e1168dc926cf2c47d529efc07eca85c0

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
