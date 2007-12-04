From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 0/11] Combined set of sysctl reworks, cleanups
 and fixes
Date: Tue, 04 Dec 2007 13:01:19 +0300
Message-ID: <4755256F.9000505@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59112 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbXLDKBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 05:01:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David.

Herbert has accepted a set of patches with sysctl paths from Eric.
The idea of the path is to eliminate the ctl_table-s that are used
merely to denote the path to those tables, that really contain 
pointer on variables and proc handlers to change them. Thus, we can
significantly reduce the vmlinux size and make the code much cleaner.

Another good point of "paths" is that they help to create per-netns
sysctls. I have posted some patches, cleaning devinet and addrconf 
sysctls and they were accepted - this is the next step.

These patches depend on each other, but do some different things:

First 6 patches isolate net/core/, net/ipv4/ and net/token-ring tables
in their own .c files thus removing a some tables from the global scope.
Next two patches make the similar thing for the ipv6 sysctls.

9th patch merges handlers for two entries - sys.net.ipv4.ip_forward and
sys.net.conf.all.forwarding as they really do the same thing.

The last two patches fix discrepancy, that I found in how proc handler
and sysctl handler work for net.<proto>.conf.<any>.forwarding entry for
both ipv4 and ipv6.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

