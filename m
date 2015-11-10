From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] iproute: restrict hoplimit values to be in range [1;255]
Date: Tue, 10 Nov 2015 13:54:09 +0100
Message-ID: <1447160049-29214-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34719 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbbKJMyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 07:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Technically, the range of possible hoplimit values are defined by IPv4
and IPv6 header formats. Both define the field to be eight bits in size,
which leads to a value range of [0;255]. Setting a packet's hoplimit
field to 0 though makes not much sense, as the next hop would
immediately drop the packet. Therefore Linux uses 0 as a special value
indicating to use the system's default hoplimit (configurable via
sysctl). In iproute, setting the hoplimit of a route to 0 is equivalent
to omitting the hoplimit parameter alltogether, so it is not necessary
to allow that value to be specified.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c0ef7bf..e0c8e4c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -931,7 +931,8 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 				mxlock |= (1<<RTAX_HOPLIMIT);
 				NEXT_ARG();
 			}
-			if (get_unsigned(&hoplimit, *argv, 0))
+			if (get_unsigned(&hoplimit, *argv, 0) ||
+			    hoplimit < 1 || hoplimit > 255)
 				invarg("\"hoplimit\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_HOPLIMIT, hoplimit);
 		} else if (strcmp(*argv, "advmss") == 0) {
-- 
2.1.2
