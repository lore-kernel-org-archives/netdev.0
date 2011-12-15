From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/13] Dumping AF_UNIX sockets via netlink
Date: Thu, 15 Dec 2011 16:42:18 +0400
Message-ID: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28116 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758745Ab1LOMm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 07:42:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the unix_diag.ko module, which is the AF_UNIX client for the sock_diag.

Use the sock_i_ino() as the primary ID key for sockets. This is currently the
only unique (except for the sk address itself) ID of a unix socket and is de
facto used in the ss tool to identify sockets. Thus the basic nlk request and
response structures operate on this ID. Other socket info (sun_name, peer, etc.)
are reported in the respective NLA-s (patches 8 through 12).

There's a locking trickery in patch #11. I've tried to study it carefully and
checked with lockdep, but anyway, please, pay special attention to it.

The patch for ss tool is also included.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
