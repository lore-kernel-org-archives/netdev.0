From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] iproute: restrict hoplimit values to be in range [0;255]
Date: Tue, 24 Nov 2015 15:45:31 +0100
Message-ID: <1448376331-14527-1-git-send-email-phil@nwl.cc>
References: <20151123154844.5466a6e3@xeon-e3>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59099 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319AbbKXOpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 09:45:44 -0500
In-Reply-To: <20151123154844.5466a6e3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Technically, the range of possible hoplimit values are defined by IPv4
and IPv6 header formats. Both define the field to be eight bits in size,
which leads to a value range of [0;255]. Setting a packet's hoplimit
field to 0 though makes not much sense, as the next hop would
immediately drop the packet. Therefore Linux uses 0 as a special value
indicating to use the system's default hoplimit (configurable via
sysctl). In iproute, setting the hoplimit of a route to 0 is equivalent
to omitting the hoplimit parameter alltogether, so it is actually not
necessary to allow that value to be specified, but keep it anyway for
backwards compatibility.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Allow hoplimit 0 for backwards compatibility.
- Adjust commit message accordingly.
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c0ef7bf..aed1038 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -931,7 +931,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 				mxlock |= (1<<RTAX_HOPLIMIT);
 				NEXT_ARG();
 			}
-			if (get_unsigned(&hoplimit, *argv, 0))
+			if (get_unsigned(&hoplimit, *argv, 0) || hoplimit > 255)
 				invarg("\"hoplimit\" value is invalid\n", *argv);
 			rta_addattr32(mxrta, sizeof(mxbuf), RTAX_HOPLIMIT, hoplimit);
 		} else if (strcmp(*argv, "advmss") == 0) {
-- 
2.5.0
