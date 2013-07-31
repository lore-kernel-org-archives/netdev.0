From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60665] New: `int backlog` is assigned to `unsigned short
 sk_max_ack_backlog` -> overflow
Date: Wed, 31 Jul 2013 08:36:14 -0700
Message-ID: <20130731083614.4174035a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f66.google.com ([209.85.160.66]:60098 "EHLO
	mail-pb0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760297Ab3GaPgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 11:36:19 -0400
Received: by mail-pb0-f66.google.com with SMTP id mc8so430210pbc.5
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 08:36:19 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id py4sm2834274pbc.14.2013.07.31.08.36.18
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 31 Jul 2013 08:36:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 31 Jul 2013 06:33:07 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60665] New: `int backlog` is assigned to `unsigned short sk_max_ack_backlog` -> overflow


https://bugzilla.kernel.org/show_bug.cgi?id=60665

            Bug ID: 60665
           Summary: `int backlog` is assigned to `unsigned short
                    sk_max_ack_backlog` -> overflow
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11-rc3
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: ojab@ojab.ru
        Regression: No

I'm not sure that my analysis is correct, but:
sk_max_ack_backlog declared as unsigned short @
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/include/net/sock.h?id=refs/tags/v3.11-rc3#n377
and we're assigning `int backlog` to it @
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/ipv4/af_inet.c?id=refs/tags/v3.10.4#n239

So if we'll set sysctls "net.ipv4.tcp_abort_on_overflow=1",
"net.core.somaxconn=65536" (or larger) and backlog > 65536, we'll have real
backlog = `somaxconn mod 65536`.

So AFAIU there shouldn't be possible to set somaxconn > 65535 or this behaviour
should be fixed.

-- 
You are receiving this mail because:
You are the assignee for the bug.
