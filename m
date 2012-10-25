From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH iproute2 0/5] Teach ss to show sockets' shutdown state
Date: Thu, 25 Oct 2012 17:16:31 +0400
Message-ID: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44251 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759568Ab2JYNQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the net-next sits a patch which extends the sock-diag subsys to 
show the sockets' shutdown state. I propose to teach the ss tool to 
print this info when requested with -e|--extended key.

The output will look like arrows at the end of each line, like this:

ESTAB 0 0  127.0.0.1:41705  127.0.0.1:12345  ino:143321 sk:ffff88003a8cea00 -->
ESTAB 0 0  127.0.0.1:46925  127.0.0.1:12346  ino:143322 sk:ffff88003a8ce4c0 <--
ESTAB 0 0  127.0.0.1:51678  127.0.0.1:12347  ino:143323 sk:ffff88003a8cdf80 ---
ESTAB 0 0  127.0.0.1:46911  127.0.0.1:12348  ino:143324 sk:ffff88003b7f05c0 <->

for SHUT_RD, SHUT_WR, SHUT_RDWR and non-shutdown sockets respectively.


In order to do so, it's also required to implement support for the
newer sock-diag in tcp and udp netlink code. I did it before, but
broke compatibility with older kernels (those without sock-diag).
Now this is fixed (checked on 2.6.40 kernel).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
