From: Miao Xie <miaox@cn.fujitsu.com>
Subject: [PATCH] IPv6: datagram_send_ctl() should exit immediately when an
 error occured
Date: Wed, 30 Jul 2008 09:30:43 +0800
Message-ID: <488FC443.1080905@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Pekka Savola <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "NETWORKING [IPv4/IPv6]" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62252 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754845AbYG3BdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 21:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an error occured, datagram_send_ctl() should exit immediately rather than
continue to run the for loop. Otherwise, the variable err might be changed and
the error might be hidden.

Fix this bug by using "goto" instead of "break".

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>

---
 net/ipv6/datagram.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f7b535d..410046a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -732,7 +732,7 @@ int datagram_send_ctl(struct net *net,
 			LIMIT_NETDEBUG(KERN_DEBUG "invalid cmsg type: %d\n",
 				       cmsg->cmsg_type);
 			err = -EINVAL;
-			break;
+			goto exit_f;
 		}
 	}
 
-- 
1.5.4.rc3


