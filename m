From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 36122] New: New cache learned PMTU information in inetpeer
 causes ssh to fail when tunneled via an IPSEC VPN
Date: Wed, 8 Jun 2011 08:43:04 -0700
Message-ID: <20110608084304.358d5970@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40305 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753404Ab1FHPnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 11:43:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 28 May 2011 21:50:29 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 36122] New: New cache learned PMTU information in inetpeer causes ssh to fail when tunneled via an IPSEC VPN


https://bugzilla.kernel.org/show_bug.cgi?id=36122

               URL: http://bugs.gentoo.org/show_bug.cgi?id=369025
           Summary: New cache learned PMTU information in inetpeer causes
                    ssh to fail when tunneled via an IPSEC VPN
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.39
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: blueness@gentoo.org
                CC: kernel@gentoo.org
        Regression: No


When trying to ssh from a box running 2.6.39 on one private subnet to another
box on another private subnet via an IPSEC vpn, ssh freezes and times out at:

   debug1: expecting SSH2_MSG_KEX_DH_GEX_GROUP

This was traced down to commit 2c8cec5c10bced2408082a6656170e74ac17231c.

This type of error is known to occur when there is fragmentation due to
mismatched mtu's which the commit addresses.

Notice the problem does not occur when ssh-ing directly, ie not via an IPSEC
tunnel.  I have not tested if other tunnels are affected.

Please see the downstream bug for more details.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
