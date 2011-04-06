From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 32832] New: shutdown(2) does not fully shut down socket
 any more
Date: Wed, 6 Apr 2011 16:07:13 -0700
Message-ID: <20110406160713.7ff48ef1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43879 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756980Ab1DFXHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 19:07:47 -0400
Received: from nehalam (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p36N7Exh022063
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 16:07:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 6 Apr 2011 22:42:39 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 32832] New: shutdown(2) does not fully shut down socket any more


https://bugzilla.kernel.org/show_bug.cgi?id=32832

           Summary: shutdown(2) does not fully shut down socket any more
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.38
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: kees@outflux.net
        Regression: Yes


In 2.6.35 and earlier, shutdown(2) will fully remove a socket. This does not
appear to be true any more and is causing software to misbehave.

2.6.35:
$ ./testcase
parent: 5957
before:
tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
after:
child: 5961
$ ./testcase
parent: 6001
before:
tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
after:
child: 6002

2.6.38:
$ ./testcase
parent: 1138
before:
tcp        0      0 0.0.0.0:12345           0.0.0.0:*               LISTEN     
after:
child: 1142
$ ./testcase
bind: Address already in use

The listener doesn't show up in netstat any more, but as long as the child
process is running, the socket is unavailable. It is as if the shutdown(2)
behavior has partially reverted to close(2) behavior (but in the case of using
close(2), the child's socket would remain visible in netstat).

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
