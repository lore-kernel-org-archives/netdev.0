From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 16183] New: sch_teql no longer works post 2.6.30
Date: Fri, 11 Jun 2010 09:08:35 -0700
Message-ID: <20100611090835.31b8436c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33807 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751628Ab0FKQIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 12:08:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 11 Jun 2010 15:56:44 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 16183] New: sch_teql no longer works post 2.6.30


https://bugzilla.kernel.org/show_bug.cgi?id=16183

           Summary: sch_teql no longer works post 2.6.30
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.31 through 2.6.34
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: tom@compton.nu
        Regression: Yes


Created an attachment (id=26729)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=26729)
Patch to fix sch_teql

The sch_teql module, which can be used to load balance over a set of underlying
interfaces, stopped working after 2.6.30 and has been broken in all kernels
since then.

The problem is that the transmit routine relies on being able to access the
destination address in the skb in order to do ARP resolution once it has
decided which underlying interface it is going to transmit through.

In 2.6.31 the IFF_XMIT_DST_RELEASE flag was introduced, and set by default for
all interfaces, which causes the destination address to be release before the
transmit routine for the interface is called.

The solution (implemented in the attached patch) is to clear that flag for teql
interfaces.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
