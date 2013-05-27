From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net-next 0/6] ipv4 fixes for dmvpn
Date: Mon, 27 May 2013 14:16:10 +0300
Message-ID: <1369653376-4731-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:59968 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672Ab3E0LOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 07:14:41 -0400
Received: by mail-ea0-f182.google.com with SMTP id r16so3853806ead.41
        for <netdev@vger.kernel.org>; Mon, 27 May 2013 04:14:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Collection of pending fixes which mostly hit DMVPN setups, but some
are doing good to generic setups too.

Patches 1 & 2 fix the NOARP flag change to flush nud NOARP entries
from ARP cache. The only change from previous send is updating the
commit message per request, and adding Ben's Acked-By.

Patch 3 reworks IPsec PMTU propagation to be less invasive, and fixes
certain subtle caching issues.

Patch 4 and 5 are performance improvements. Both are especially useful
on dmvpn setups, but the latter patch helps general setups too.

And finally the patch 6 is a respin of the input route caching so
we get proper pmtu and fragmentation in forwarding path (needed for
tunnel devices and TCPMSS clamp-to-pmtu). While it would be better if
we could avoid input route caching, this was the only non-intrusive way
to fix all issues I came up with.

The whole patchset is tested on top of 3.9.x and fixes the issues
I've encountered.

Please review and consider applying to net-next.

Timo Ter=C3=A4s (6):
  net: inform NETDEV_CHANGE callbacks which flags were changed
  arp: flush arp cache on IFF_NOARP change
  ipv4: properly refresh rtable entries on pmtu/redirect events
  ipv4: rate limit updating of next hop exceptions with same pmtu
  ipv4: use separate genid for next hop exceptions
  ipv4: use next hop exceptions also for input routes

 include/linux/netdevice.h   |   4 +-
 include/net/ip_fib.h        |   4 +-
 include/net/net_namespace.h |  11 ++++
 net/core/dev.c              |   5 +-
 net/ipv4/ah4.c              |   7 +--
 net/ipv4/arp.c              |   4 ++
 net/ipv4/esp4.c             |   7 +--
 net/ipv4/fib_semantics.c    |   3 +-
 net/ipv4/ipcomp.c           |   7 +--
 net/ipv4/route.c            | 140 +++++++++++++++++++++++++++++++-----=
--------
 10 files changed, 132 insertions(+), 60 deletions(-)

--=20
1.8.2.3
