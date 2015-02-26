From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net 2/2] net: Verify permission to link_net in newlink
Date: Thu, 26 Feb 2015 16:20:07 -0600
Message-ID: <877fv4mi20.fsf_-_@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>
	<54EEDF9C.20302@6wind.com> <87wq34okb9.fsf@x220.int.ebiederm.org>
	<54EF3338.8000409@6wind.com> <87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:34747 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbBZWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:23:36 -0500
In-Reply-To: <87egpcmi3v.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 26 Feb 2015 16:19:00 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When applicable verify that the caller has permisson to the underlying
network namespace for a newly created network device.

Similary checks exist for the network namespace a network device will
be created in.

Fixes: v4.0-rc1
Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/rtnetlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 155e675f656c..0a0b1c081d68 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2134,6 +2134,9 @@ replay:
 				err =  -EINVAL;
 				goto out;
 			}
+			err = -EPERM;
+			if (!netlink_ns_capable(skb, link_net->user_ns, CAP_NET_ADMIN))
+				goto out;
 		}
 
 		dev = rtnl_create_link(link_net ? : dest_net, ifname,
-- 
2.2.1
