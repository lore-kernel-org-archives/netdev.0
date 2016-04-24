From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2 3/3] gre: allow creation of gretap interfaces in metadata mode
Date: Sun, 24 Apr 2016 13:00:22 +0200
Message-ID: <4917335385a75586c1f13b6a6d570d4cc5b0b132.1461495411.git.jbenc@redhat.com>
References: <cover.1461495411.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbcDXLAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 07:00:46 -0400
In-Reply-To: <cover.1461495411.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IFLA_GRE_REMOTE attribute does not make sense together with collect
metadata and is ignored in such case. However, iproute2 always sets it; it
will be zero if there's no remote address specified on the command line.

Remove the check for non-zero IFLA_GRE_REMOTE when collect medata flag is
set.

Before the patch, this command returns failure, after the patch, it works as
expected:

ip link add gre1 type gretap external

Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
New in v2.
---
 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 02b12db59437..27716c72b8e2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -974,7 +974,7 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (!data)
 		goto out;
 
-	if (data[IFLA_GRE_REMOTE]) {
+	if (data[IFLA_GRE_REMOTE] && !data[IFLA_GRE_COLLECT_METADATA]) {
 		memcpy(&daddr, nla_data(data[IFLA_GRE_REMOTE]), 4);
 		if (!daddr)
 			return -EINVAL;
-- 
1.8.3.1
