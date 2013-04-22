From: David Miller <davem@davemloft.net>
Subject: you must fix this
Date: Mon, 22 Apr 2013 16:23:01 -0400 (EDT)
Message-ID: <20130422.162301.2219305973270706624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab3DVUXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You CANNOT call into functional ipv6 functions from unrelated
kernel modules:

net/built-in.o: In function `ip_tunnel_xmit':
/home/davem/src/GIT/net-next/net/ipv4/ip_tunnel.c:619: undefined reference to `icmpv6_send'

There is no way I can allow this, it requires a call into IPV6 proper
to a function that cannot be added to one of the source files we
force building statically into the kernel such as addrconf_core.c

Right now things are completely broken with IPV6=y and everything
else modular, and that is not acceptable.

DO NOT fix this by adding Kconfig dependencies, and DO NOT fix this
by mucking with ugly ifdefs the ip_tunnel.c

You have to remove this need to call into a stateful portion of
the IPV6 code, portions which cannot be moved into simply helper
functions which get statically linked into the kernel.
