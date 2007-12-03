From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 9493] New: routing table bug or feature
 adding/replacing/deleting routes
Date: Mon, 3 Dec 2007 15:08:03 -0800
Message-ID: <20071203150803.71dbf0bf@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33411 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbXLCXJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 18:09:22 -0500
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id lB3N8nZK027886
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Dec 2007 15:08:51 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon,  3 Dec 2007 11:23:27 -0800 (PST)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 9493] New: routing table bug or feature adding/replacing/deleting routes


http://bugzilla.kernel.org/show_bug.cgi?id=9493

           Summary: routing table bug or feature adding/replacing/deleting
                    routes
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.23
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: green@msu.ru


Most recent kernel where this bug did not occur: unknown
Distribution: Ubuntu (kernel 2.6.22-14), Gentoo (kernel 2.6.23-gentoo-r3)
Hardware Environment: x86
Software Environment:
Steps to reproduce:
(eth0 is 172.16.32.0/22):
$ ip route add 172.17.0.1 via 172.16.32.1
$ ip route append 172.17.0.1 via 172.16.35.1
$ ip ro
...
172.17.0.1 via 172.16.32.1 dev eth0
172.17.0.1 via 172.16.35.1 dev eth0
...
$ ip ro replace 172.17.0.1 via 172.16.35.1
$ ip ro
...
172.17.0.1 via 172.16.35.1 dev eth0
172.17.0.1 via 172.16.35.1 dev eth0
...
$ ip ro del 172.17.0.1
$ ip ro
...
172.17.0.1 via 172.16.35.1 dev eth0
...

Problem Description:
Is it OK:
- only 1 route is deleted?
- only 1 route is replaced?
- replacing route results in dublicate routing table entry?
Is this a bug or feature?


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
