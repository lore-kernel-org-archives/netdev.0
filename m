From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 18822] New: TCP Communications gets blocked, then resetted
Date: Mon, 20 Sep 2010 09:04:51 -0700
Message-ID: <20100920090451.4ef28f91@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41740 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752275Ab0ITQFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 12:05:04 -0400
Received: from nehalam (pool-74-107-135-205.ptldor.fios.verizon.net [74.107.135.205])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o8KG4vYC022382
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 09:05:02 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 20 Sep 2010 10:39:47 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 18822] New: TCP Communications gets blocked, then resetted


https://bugzilla.kernel.org/show_bug.cgi?id=18822

           Summary: TCP Communications gets blocked, then resetted
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32-24-generic #43-Ubuntu
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: dc6iq@gmx.de
        Regression: No


Created an attachment (id=30682)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=30682)
both machine dumps

having a freshly installed bacula server i could never get a backup from my
working machine done to the bacula server.

The Connection transmits approximately 3 GiB, then locks up and resets the
connection.

Transmission gets stuck at a certain point, then the bacula server does not
reply to retransmitted packets on IPV4 stack. Retry Count on disks machine (my
working machine) raises up to 13, then the Connection is gone. bacula server
tries to send a Push packet (after KeepAlive timer runs out), and get the final
RST packet from disks, because the connection is gone.

In the Attachment you will find the tcpdumps from both machines, actually the
sending machine dropped some packets in the dump.

It might be a possible help: disks is running an 64 bit kernel whereas bacula
is running 32 bit. I haven't looked into the option bits very well but it looks
like there is a problem hidden:

last ack being ok:
09:32:56.142876 IP bacula.elkenet.bacula-sd > disks.elkenet.50766: Flags [.],
ack 2005754588, win 9582, options [nop,nop,TS val 21825875 ecr 4530083], length
0
next ack packet:
09:32:56.144763 IP bacula.elkenet.bacula-sd > disks.elkenet.50766: Flags [.],
ack 2005773412, win 9308, options [nop,nop,TS val 21825876 ecr
4530083,nop,nop,sack 1 {2005774860:2005776308}], length 0

root@disks:~# uname -a
Linux disks 2.6.32-24-generic #43-Ubuntu SMP Thu Sep 16 14:58:24 UTC 2010
x86_64 GNU/Linux

root@bacula:~# uname -a
Linux bacula 2.6.32-24-generic-pae #43-Ubuntu SMP Thu Sep 16 15:30:27 UTC 2010
i686 GNU/Linux

Doing a 20GB backup on a debian server works fine

server:~# uname -a
Linux server 2.6.32-5-486 #1 Sat Sep 18 01:43:00 UTC 2010 i686 GNU/Linux

Doing a 26 GB backup from a 32 bit Ubuntu works fine as well. Maybe its a 64
bit issue...

root@elke:~# uname -a
Linux elke 2.6.32-24-generic #43-Ubuntu SMP Thu Sep 16 14:17:33 UTC 2010 i686
GNU/Linux

If any further input is required, just let me know...

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
