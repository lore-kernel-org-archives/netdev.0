From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] rps: support IPIP encapsulation
Date: Wed, 24 Aug 2011 22:41:19 +0200
Message-ID: <1314218479.2506.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36848 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab1HXUlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 16:41:24 -0400
Received: by wyg24 with SMTP id 24so1148782wyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 13:41:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip IPIP header to get proper layer-4 information.

Like GRE tunnels, this only works if rxhash is not already provided by
the device itself (ethtool -K ethX rxhash off), to allow kernel compute
a software rxhash.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
A piece of cake ;)

 net/core/dev.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index a4306f7..b668a3d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2608,6 +2608,8 @@ again:
 			}
 		}
 		break;
+	case IPPROTO_IPIP:
+		goto again;
 	default:
 		break;
 	}
