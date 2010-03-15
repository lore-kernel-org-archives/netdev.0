From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 15541] New: POLLIN bit is set when there is OOB data only
Date: Mon, 15 Mar 2010 10:26:02 -0700
Message-ID: <20100315102602.0d844cc7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44252 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965582Ab0COR0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 13:26:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 15 Mar 2010 16:19:44 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 15541] New: POLLIN bit is set when there is OOB data only


http://bugzilla.kernel.org/show_bug.cgi?id=15541

           Summary: POLLIN bit is set when there is OOB data only
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.28, 2.6.32, 2.6.33
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: Alexandra.Kossovsky@oktetlabs.ru
                CC: davem@davemloft.net
        Regression: Yes


Starting from 2.6.28, Linux kernel has incorrect behaviour when poll() is
called on TCP socket with out-of-band byte received.

When TCP socket has OOB byte available (and no normal data), old Linux,
Solaris, FreeBSD and other systems return POLLPRI bit without POLLRD.  Starting
from 2.6.28, Linux returns POLLRD | POLLPRI | POLLRDNORM.

The broken commt is
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.28.y.git;a=commitdiff;h=c7004482e8dcb7c3c72666395cfa98a216a4fb70
.
Following 1-line patch fixes the problem:
--- a/net/ipv4/tcp.c 2010-03-15 19:13:45.000000000 +0300
+++ b/net/ipv4/tcp.c      2010-03-15 19:13:21.000000000 +0300
@@ -428,7 +428,7 @@
                if (tp->urg_seq == tp->copied_seq &&
                    !sock_flag(sk, SOCK_URGINLINE) &&
                    tp->urg_data)
-                       target--;
+                       target++;

                /* Potential race condition. If read of tp below will
                 * escape above sk->sk_state, we can be illegally awaken

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
