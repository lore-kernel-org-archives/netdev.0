From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 02/02: xt_connlimit: fix regression caused by zero
 family value
Date: Fri, 6 Nov 2009 11:17:57 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0911061115480.6160@obet.zrqbmnf.qr>
References: <4AF31818.3030103@trash.net> <alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr> <20091106.004418.54906158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091106.004418.54906158.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-11-06 09:44, David Miller wrote:

>From: Jan Engelhardt <jengelh@medozas.de>
>Date: Thu, 5 Nov 2009 19:45:25 +0100 (CET)
>
>> On Thursday 2009-11-05 19:23, Patrick McHardy wrote:
>>>
>>>    netfilter: xt_connlimit: fix regression caused by zero family value
>>>    
>>>    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
>>>    instances of par->match->family were changed to par->family.
>>>    
>>>    Netfilter bugzilla #610.
>> 
>> Hold it.
>> git would never output ~7172~1092~2 because ~8266 would be much simpler.
>> 
>> I originally wrote "Commit v2.6.28-rc1~717^2~109^2~2", but one of your 
>> programs seems to eat commit messages or more.
>
>Guys, please sort this out so I can add this fix to net-2.6
>
>Thanks.

This should.


commit ffffffffffffffffffffffffffffffffffffffff
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Nov 4 14:27:30 2009 +0100

netfilter: xt_connlimit: fix regression caused by zero family value
Commit v2.6.28-rc1~717^2~109^2~2 was slightly incomplete; not all
instances of par->match->family were changed to par->family.

References: http://bugzilla.netfilter.org/show_bug.cgi?id=610
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6809809..38f03f7 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -103,7 +103,7 @@ static int count_them(struct xt_connlimit_data *data,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      const struct xt_match *match)
+		      u_int8_t family)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
@@ -113,8 +113,7 @@ static int count_them(struct xt_connlimit_data *data,
 	bool addit = true;
 	int matches = 0;
 
-
-	if (match->family == NFPROTO_IPV6)
+	if (family == NFPROTO_IPV6)
 		hash = &data->iphash[connlimit_iphash6(addr, mask)];
 	else
 		hash = &data->iphash[connlimit_iphash(addr->ip & mask->ip)];
@@ -157,8 +156,7 @@ static int count_them(struct xt_connlimit_data *data,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3,
-		    match->family))
+		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
 			/* same source network -> be counted! */
 			++matches;
 		nf_ct_put(found_ct);
@@ -207,7 +205,7 @@ connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 	spin_lock_bh(&info->data->lock);
 	connections = count_them(info->data, tuple_ptr, &addr,
-	                         &info->mask, par->match);
+	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
 	if (connections < 0) {
-- 
# Created with git-export-patch
