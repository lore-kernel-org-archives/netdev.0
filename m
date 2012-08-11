From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 45571] New: The kernel disallows to reuse sockets which
 have TIME_WAIT pending connections
Date: Sat, 11 Aug 2012 11:09:02 -0700
Message-ID: <20120811110902.640d1042@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56710 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258Ab2HKSJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Aug 2012 14:09:15 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 84906141056E
	for <netdev@vger.kernel.org>; Sat, 11 Aug 2012 11:09:12 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7hKq+k+Wp7ri for <netdev@vger.kernel.org>;
	Sat, 11 Aug 2012 11:09:08 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 2C68A1410136
	for <netdev@vger.kernel.org>; Sat, 11 Aug 2012 11:09:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat,  4 Aug 2012 11:13:11 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 45571] New: The kernel disallows to reuse sockets which have TIME_WAIT pending connections


https://bugzilla.kernel.org/show_bug.cgi?id=45571

           Summary: The kernel disallows to reuse sockets which have
                    TIME_WAIT pending connections
           Product: Networking
           Version: 2.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: t.artem@mailcity.com
        Regression: No


This is a follow up of the following bug report:
http://bugs.winehq.org/show_bug.cgi?id=26031

It's not Wine's problem, as it can be easily reproduced with native Linux
applications.

Bruno Jesus 2011-11-10 21:35:54 CST wrote:

> Well, after reading a lot of internet pages and trying several different
> attempts I think it's possible to say that it's a kernel bug or a
> characteristic of the kernel tcp implementation.
> 
> The attached patch forces SO_REUSEADDR in before every bind in an attempt to
> fix the problem but it only works if the program exits cleanly (so the kernel
> sets the socket to TIME_WAIT), if you do "wineserver -k" the socket will remain
> opened in an unknow broken state and no applications will be able to use it
> (wine or native linux apps).
> 
> Output of strace:
> getsockopt(24, SOL_SOCKET, SO_REUSEADDR, [0], [4]) = 0
> setsockopt(24, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(24, {sa_family=AF_INET, sin_port=htons(43012), sin_addr=inet_addr("0.     
> 0.0.0")}, 16) = -1 EADDRINUSE (Address already in use)
> 
> It's possible to see that I'm checking if SO_REUSEADDR is enabled and then
> enable it. But the bind fails anyway.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
