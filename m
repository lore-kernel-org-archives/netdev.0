From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 12014] New: Incorrect Urgent Pointer in outgoing packets
Date: Wed, 12 Nov 2008 08:27:35 -0800
Message-ID: <20081112082735.5aa06a15@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47261 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966AbYKLQ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 11:27:44 -0500
Received: from extreme (pool-96-225-231-79.ptldor.fios.verizon.net [96.225.231.79] (may be forged))
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id mACGRfUG004268
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 08:27:43 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 12 Nov 2008 02:16:33 -0800 (PST)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 12014] New: Incorrect Urgent Pointer in outgoing packets


http://bugzilla.kernel.org/show_bug.cgi?id=12014

           Summary: Incorrect Urgent Pointer in outgoing packets
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.27
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: kernel@tesarici.cz


Latest working kernel version: ??? (maybe never)
Earliest failing kernel version: 2.6.27
Distribution: kernel.org
Hardware Environment: x86, x86_64
Software Environment: Oracle, testcase
Problem Description:

When urgent mode is initiated using send(..., MSG_OOB), and the current
outgoing queue is longer than MTU, several packets are sent out with the URG
flag set. However, the Urgent Pointer field in the TCP header is not updated
correctly. Instead, it stays the same.

The receiving end interprets this as a new urgent message inserted further in
the stream, sends multiple SIGURGs to the server application and reads across
the urgent data. This behaviour is correct.

Steps to reproduce:

1. Initiate a TCP connection
2. Fill the outgoing queue with some (normal) data
3. Send an urgent message (with MSG_OOB)
4. Send some more non-urgent data.


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
