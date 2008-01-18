From: "Denis V. Lunev" <den@sw.ru>
Subject: [PATCH 0/4 net-2.6.25] Proper netlink kernel sockets disposal.
Date: Fri, 18 Jan 2008 15:51:47 +0300
Message-ID: <4790A0E3.9080006@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:56623 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758104AbYARMvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 07:51:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan found, that virtualized netlink kernel sockets (fibl &
rtnl) are leaked during namespace start/stop loop.

Leaking fix (simple and obvious) reveals that netlink kernel socket
disposal leads to OOPSes:
- nl_table[protocol]->listeners is double freed
- sometimes during namespace stop netlink_sock_destruct
  BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc)); is hit

This set address all these issues.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Tested-by: Alexey Dobriayn <adobriyan@openvz.org>

