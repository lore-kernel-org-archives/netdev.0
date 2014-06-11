From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 2/2] bridge: fix compile error when compiling without IPv6 support
Date: Thu, 12 Jun 2014 01:41:24 +0200
Message-ID: <1402530084-15061-3-git-send-email-linus.luessing@web.de>
References: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:57148 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411AbaFKXkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 19:40:43 -0400
In-Reply-To: <1402530084-15061-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some fields in "struct net_bridge" aren't available when compiling the
kernel without IPv6 support. Therefore adding a check/macro to skip the
complaining code sections in that case.

Introduced by 2cd4143192e8c60f66cb32c3a30c76d0470a372d
("bridge: memorize and export selected IGMP/MLD querier port")

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 876e5fb..abfa0b65 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -2246,11 +2246,13 @@ bool br_multicast_has_querier_adjacent(struct n=
et_device *dev, int proto)
 		    rcu_dereference(br->ip4_querier.port) =3D=3D port)
 			goto unlock;
 		break;
+#if IS_ENABLED(CONFIG_IPV6)
 	case ETH_P_IPV6:
 		if (!timer_pending(&br->ip6_other_query.timer) ||
 		    rcu_dereference(br->ip6_querier.port) =3D=3D port)
 			goto unlock;
 		break;
+#endif
 	default:
 		goto unlock;
 	}
--=20
1.7.10.4
