From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/11] Generalize the inet_diag infrastructure
Date: Tue, 06 Dec 2011 21:56:10 +0400
Message-ID: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48238 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab1LFR4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:56:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an attempt to prepare the existing inet_diag infrastructure to work with
arbitrary address family and protocol pair, not only AF_INET(6) and TCP/DCCP.

This set adds the sock_diag infrastructure, that handles the new SOCK_DIAG_BY_FAMILY
message type by the NETLINK_INET_DIAG socket. The core API struct for this (called
sock_diag_req) contains two fields - family and type - which specify which sockets 
to dump. Additional information is considered to be family handler specific.

The existing inet_diag code is patched to register himself inside the sock_diag and
provide callbacks for dumping AF_INET/AF_INET6 IPPROTO_TCP/IPPROTO_DCCP sockets. The
existing API facilities such as state filtering and bytecode is of course preserved
and is treated by inet_diag specific data.

Binary compatibility with existing NETLINK_INET_DIAG is also kept.

No additional stuff in this set. The support for IPPROTO_UDP protocol and AF_UNIX
family will come later if this set is approved.

Applies to net-next, patch for iproute2's ss tool (proving that the new code ... pretends
to work) is at the end of the thread.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
