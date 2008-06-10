From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC][PATCH 1/3] IPv6:Check the outgoing hop limit value
Date: Tue, 10 Jun 2008 15:50:55 +0800
Message-ID: <484E325F.4010102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52490 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbYFJHvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 03:51:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When specifing the outgoing hop limit as ancillary data for sendmsg(),
the kernel doesn't check the integer hop limit value as specified in 
[RFC-3542] section 6.3.


Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/datagram.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index b9c2de8..0f0f94a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -705,6 +705,11 @@ int datagram_send_ctl(struct net *net,
 			}
 
 			*hlimit = *(int *)CMSG_DATA(cmsg);
+			if (*hlimit < -1 || *hlimit > 0xff) {
+				err = -EINVAL;
+				goto exit_f;
+			}
+
 			break;
 
 		case IPV6_TCLASS:
-- 

