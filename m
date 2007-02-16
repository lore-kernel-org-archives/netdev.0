From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Thu, 15 Feb 2007 16:04:05 -0800
Message-ID: <20070215160405.3bd30b05@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:39469 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422779AbXBPAGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:06:53 -0500
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id l1G06phB000839
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 16:06:51 -0800
Received: from localhost.localdomain (dxpl.pdx.osdl.net [10.8.0.74])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id l1G06pZd013119
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 16:06:51 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Someone want to take a stab at fixing this??

Begin forwarded message:

Date: Wed, 14 Feb 2007 19:32:52 -0800
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 8013] New: select for write hangs on a socket after write
returned ECONNRESET


http://bugzilla.kernel.org/show_bug.cgi?id=8013

           Summary: select for write hangs on a socket after write
returned ECONNRESET
    Kernel Version: 2.6.16
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: ajd@gentrack.com


Distribution: Debian
Also reproduced on: 2.4 based Redhat.

Hardware Environment:
i686/Xeon
Problem Description:

If you write() to a disconnected socket, write returns ECONNRESET.
If you then select() on that socket, checking for write, the select
never returns.

For example from strace:
write(4, "fred", 4)                     = 4
...
write(4, "fred", 4)                     = -1 ECONNRESET (Connection
reset by peer)
select(5, NULL, [4], NULL, NULL ... hung in select

The select documentation says "those in writefds will be watched to see
if a write will not block".
A write on this socket will not block, therefore select should return 
immediately.

When the program is run on Solaris, AIX and HPUX, the select returns 
immediately.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
