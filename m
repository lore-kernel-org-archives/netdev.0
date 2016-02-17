From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] rtnl: RTM_GETNETCONF: fix wrong return value
Date: Tue, 16 Feb 2016 21:43:16 -0500
Message-ID: <1455676996-6335-1-git-send-email-a.s.protopopov@gmail.com>
Cc: Anton Protopopov <a.s.protopopov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An error response from a RTM_GETNETCONF request can return the positive
error value EINVAL in the struct nlmsgerr that can mislead userspace.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 net/ipv4/devinet.c  | 2 +-
 net/ipv6/addrconf.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cebd9d3..f6303b1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1847,7 +1847,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = EINVAL;
+	err = -EINVAL;
 	if (!tb[NETCONFA_IFINDEX])
 		goto errout;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9efd9ff..bdd7eac 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -583,7 +583,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = EINVAL;
+	err = -EINVAL;
 	if (!tb[NETCONFA_IFINDEX])
 		goto errout;
 
-- 
2.6.5
