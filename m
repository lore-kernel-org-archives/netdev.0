From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 194723] New: connect() to localhost stalls after 4.9 ->
 4.10 upgrade
Date: Mon, 27 Feb 2017 08:38:20 -0800
Message-ID: <20170227083820.687be6ac@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36571 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdB0Skv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:40:51 -0500
Received: by mail-pg0-f44.google.com with SMTP id s67so47338349pgb.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:40:40 -0800 (PST)
Received: from xeon-e3 (204-195-18-65.wavecable.com. [204.195.18.65])
        by smtp.gmail.com with ESMTPSA id t184sm31875709pgb.11.2017.02.27.08.38.27
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Feb 2017 08:38:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 27 Feb 2017 11:28:51 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 194723] New: connect() to localhost stalls after 4.9 -> 4.10 upgrade


https://bugzilla.kernel.org/show_bug.cgi?id=194723

            Bug ID: 194723
           Summary: connect() to localhost stalls after 4.9 -> 4.10
                    upgrade
           Product: Networking
           Version: 2.5
    Kernel Version: 4.10
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: lvml@5t9.de
        Regression: No

After upgrading a machine running the latest CentOS from using mainline kernel
linux-4.9 to linux-4.10, attempts to connect() via IPv4 to localhost fail in
about half of the cases, leaving the process trying to connect() stalled.

Reproduction:

> ncat -k -l 19999 &
> C=1 ; while true ; do echo -n "$C " ; echo ping | ncat localhost 19999 ;
> C=`expr $C + 1` ; sleep 1 ; done  

Using linux-4.10, the output looks like this:

> 1 ping
> 2 Ncat: Connection timed out.
> 3 ping
> 4 Ncat: Connection timed out.
> 5 ping
> 6 ping
> 7 ping
> 8 Ncat: Connection timed out.
> 9 ping
> 10 ping
> 11 Ncat: Connection timed out.
> 12 ping
> 13 Ncat: Connection timed out.
> 14 ping
> 15 Ncat: Connection timed out.
> 16 ping
> 17 Ncat: Connection timed out.
> 18 ping
> 19 ping
> 20 Ncat: Connection timed out.
> 21 ping
> 22 ping
> 23 Ncat: Connection timed out.
> 24 ping
> 25 Ncat: Connection timed out.
> 26 Ncat: Connection timed out.
> 27 ping
> 28 Ncat: Connection timed out.
> 29 ping  


Using linux-4.9, the output looks like this:

> 1 ping
> 2 ping
> 3 ping
> 4 ping
> 5 ping
> 6 ping
> 7 ping
> 8 ping
> 9 ping
> 10 ping
> 11 ping
> 12 ping
> 13 ping
> 14 ping
> 15 ping
> 16 ping
> 17 ping
> 18 ping
> 19 ping  

(The same behaviour was later also confirmed by a colleague on an Ubuntu
running machine after upgrading to Ubuntu's 4.10 kernel.)

-- 
You are receiving this mail because:
You are the assignee for the bug.
