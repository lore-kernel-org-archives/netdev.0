From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH ] ipv6: handle the update of the NDISC_REDIRECT error code
 in icmpv6_err_convert
Date: Wed, 18 Sep 2013 20:04:48 +0800
Message-ID: <523996E0.9080702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15467 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752062Ab3IRMFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 08:05:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

when dealing with redirect message in udpv6_err() and
rawv6_err() the err shoud be assigned to 0, not EPROTO.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/icmp.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index eef8d94..795f348 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -977,6 +977,9 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
 	case ICMPV6_TIME_EXCEED:
 		*err = EHOSTUNREACH;
 		break;
+	case NDISC_REDIRECT:
+		*err = 0;
+		break;
 	}
 
 	return fatal;
-- 
1.8.3.1
