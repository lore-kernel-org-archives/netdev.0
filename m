From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv6: route templates missing protocol value
Date: Wed, 20 May 2009 12:30:38 -0700
Message-ID: <20090520123038.5bb2a2da@nehalam>
References: <4A0EA766.9090008@6wind.com>
	<4A11B52D.8030105@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55441 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755660AbZETTan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 15:30:43 -0400
In-Reply-To: <4A11B52D.8030105@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IPV6 routing templates are missing the protocol value so
when they are used, the routes have the protocol RTPROT_UNSPEC (0).
This confuses Zebra routing protocol daemon that makes kernel routes
a special case. This was first noticed by Jean-Mickael Guerin
who wrote this patch.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv6/route.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

--- a/net/ipv6/route.c	2009-05-15 13:32:34.138684428 -0700
+++ b/net/ipv6/route.c	2009-05-20 12:26:19.435815459 -0700
@@ -137,6 +137,7 @@ static struct rt6_info ip6_null_entry_te
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol	= RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
@@ -159,6 +160,7 @@ static struct rt6_info ip6_prohibit_entr
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol	= RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
@@ -176,6 +178,7 @@ static struct rt6_info ip6_blk_hole_entr
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_protocol	= RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
