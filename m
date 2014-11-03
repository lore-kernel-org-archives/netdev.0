From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net 0/4] ipv6: Fix iflink setting for ipv6 tunnels
Date: Mon, 3 Nov 2014 09:19:26 +0100
Message-ID: <1415002770-5797-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35468 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbaKCIUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 03:20:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 tunnels do the dev->iflink setting too early, it gets
overwritten by register_netdev(). So set dev->iflink from within
a ndo_init function to keep the configured setting.

This patchset fixes this for ip6_tunnel, vti6, sit and gre6.
