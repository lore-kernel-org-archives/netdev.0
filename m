From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH] iputils: arping fails to set correct broadcast address
Date: Fri, 13 Aug 2010 11:44:56 +0200
Message-ID: <1281692696.23856.37.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 585591@bugs.debian.org,
	Noah Meyerhans <noahm@debian.org>, Paul Martin <pm@debian.org>,
	hawk@comx.dk
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:37925 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0HMJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 05:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Paul Martin <pm@debian.org>

There seems to have been introduced a bug in iputils release s20100418.

This patch is based upon git://www.linux-ipv6.org/gitroot/iputils.git
(git commit fe342ca3148)

The regression is caused by commit 56018bf1b3
 arping: Support link-layer type with larger link-layer address.

As reported by: Paul Martin <pm@debian.org> in Debian bugreport #585591.

 There's a logic error in the function that parses the interface's
 broadcast address, causing it not to fill the broadcast address array
 correctly.

Please apply.

Reported-by: Paul Martin <pm@debian.org>
Tested-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 arping.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arping.c b/arping.c
index 9bd6927..2613a12 100644
--- a/arping.c
+++ b/arping.c
@@ -336,7 +336,7 @@ void set_device_broadcast(char *device, unsigned char *ba, size_t balen)
 	}
 
 	for (p = ba, ch = 0; p < ba + balen; p++, ch += 3)
-		*p++ = strtoul(brdcast->value + ch * 3, NULL, 16);
+		*p = strtoul(brdcast->value + ch, NULL, 16);
 
 	return;
 }


