From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] IPROUTE: generate compat messages that match
	nla_parse_nested_compat
Date: Wed, 27 Aug 2008 18:13:47 -0700
Message-ID: <20080828011347.7987.24759.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:41522 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbYH1BNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:13:50 -0400
Received: by rv-out-0506.google.com with SMTP id k40so130986rvb.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 18:13:50 -0700 (PDT)
In-Reply-To: <20080828011340.7987.74684.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch updates libnetlink.c to generate nested compat netlink
attributes in the same format that is parsed by the kernels 2.6.26
and newer.

This patch will fix the prio multiqueue option for 2.6.26 kernels,
but will break compatibility with all kernels prior to 2.6.26.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 lib/libnetlink.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5ae64f7..5f42ec1 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -573,7 +573,6 @@ struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type,
 	struct rtattr *start = NLMSG_TAIL(n);
 
 	addattr_l(n, maxlen, type, data, len);
-	addattr_nest(n, maxlen, type);
 	return start;
 }
 
@@ -582,7 +581,6 @@ int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *start)
 	struct rtattr *nest = (void *)start + NLMSG_ALIGN(start->rta_len);
 
 	start->rta_len = (void *)NLMSG_TAIL(n) - (void *)start;
-	addattr_nest_end(n, nest);
 	return n->nlmsg_len;
 }
 

