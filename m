From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 73021] New: TCP_USER_TIMEOUT not working when interface is
 taken down, e.g. cable unplugged
Date: Thu, 27 Mar 2014 09:02:02 -0700
Message-ID: <20140327090202.673380a1@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:40580 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaC0QCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:02:05 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so3644346pbb.26
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:02:05 -0700 (PDT)
Received: from samsung-9 ([12.232.193.53])
        by mx.google.com with ESMTPSA id pl10sm10688690pbb.56.2014.03.27.09.02.04
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Mar 2014 09:02:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 27 Mar 2014 05:49:28 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 73021] New: TCP_USER_TIMEOUT not working when interface is taken down, e.g. cable unplugged


https://bugzilla.kernel.org/show_bug.cgi?id=73021

            Bug ID: 73021
           Summary: TCP_USER_TIMEOUT not working when interface is taken
                    down, e.g. cable unplugged
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4.24 and 3.11.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: pelle.johnsen@gmail.com
        Regression: No

When the network interface is taken down (in this case eth0 plugging out cable)
an established socket goes to zero window probing state (netstat -o shows
unkn-4). This state ignores TCP_USER_TIMEOUT (and any keep-alive timeouts) and
result is that socket takes ~12 min. to timeout instead of what is specified
with TCP_USER_TIMEOUT.

There seems to be 2 'issues':

1. Why does socket go to zero window probing in this case?

2. Why does zero window probing not respect TCP_USER_TIMEOUT?

Expected behavior:

TCP_USER_TIMEOUT can be used to limit how long it takes a socket to timeout.

-- 
You are receiving this mail because:
You are the assignee for the bug.
