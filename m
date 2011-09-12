From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH] Check net->nfnl for NULL in ctnetlink_conntrack_event to,
 avoid Oops on container destroy
Date: Mon, 12 Sep 2011 12:03:13 -0600
Message-ID: <4E6E4961.9070802@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060909040203070706070500"
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: kaber@trash.net, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060909040203070706070500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Patrick,

I received this patch from a developer that uses lxc and network name 
spaces. I don't know the locking semantics well enough for CT to judge 
whether this fix is sufficient. Bug info can be found at 
http://bugs.launchpad.net/bugs/843892 . See comment #7 for his analysis.

rtg
-- 
Tim Gardner tim.gardner@canonical.com

--------------060909040203070706070500
Content-Type: text/x-patch;
 name="0001-Check-net-nfnl-for-NULL-in-ctnetlink_conntrack_event.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-Check-net-nfnl-for-NULL-in-ctnetlink_conntrack_event.pa";
 filename*1="tch"

>From dcb64e27c7daaf4affe5b1a617b45a9a0364b4ad Mon Sep 17 00:00:00 2001
From: Alex Bligh <alex@alex.org.uk>
Date: Sat, 10 Sep 2011 13:29:12 +0100
Subject: [PATCH] Check net->nfnl for NULL in ctnetlink_conntrack_event to
 avoid Oops on container destroy


Signed-off-by: Alex Bligh <alex@alex.org.uk>
---
 net/netfilter/nf_conntrack_netlink.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 482e90c..0790d0a 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		return 0;
 
 	net = nf_ct_net(ct);
+
+	/* container deinit, netlink may have died before death_by_timeout */
+	if (!net->nfnl)
+		return 0;
+
 	if (!item->report && !nfnetlink_has_listeners(net, group))
 		return 0;
 
-- 
1.7.5.4


--------------060909040203070706070500--
