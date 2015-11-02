From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] mpls: Don't accept multipath configuration until the support is complete
Date: Mon, 02 Nov 2015 13:29:17 -0600
Message-ID: <87egg8ryia.fsf@x220.int.ebiederm.org>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48105 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbKBThP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:37:15 -0500
In-Reply-To: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Thu, 29 Oct 2015 08:49:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently the multipath code has a nasty failure mode in that it will
fail to notice link down or administrative device down and will
instead black hole packets instead of sending them to their nexthop
destination.

Half the point of multipath is to gracefully handle forwarding path
failures and as the current code does not handle forwarding failures the
current code is dangerous to use.

As mpls multipath has never been exported to userspace and as the
implementation was not complete before the merge window disable the mpls
multipath code by rejecting all multipath configuration requests.  This
will give us another kernel development cycle to cleanly sort out the
issues, without any bad precedents to worry about.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750148b6..893cd2dc3979 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1162,6 +1162,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 		{
 			cfg->rc_mp = nla_data(nla);
 			cfg->rc_mp_len = nla_len(nla);
+			/* Fail until multipath support is complete */
+			goto errout;
 			break;
 		}
 		default:
-- 
2.2.1
