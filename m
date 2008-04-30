From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: [PATCH][IP] Make use of the inline function dst_metric_locked()
Date: Wed, 30 Apr 2008 10:18:45 +0900
Message-ID: <4817C8F5.7060101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470AbYD3BV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 21:21:57 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3U1Lvrp020415
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 21:21:57 -0400
Received: from pobox.nrt.redhat.com (pobox.nrt.redhat.com [10.64.255.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m3U1Ltaq004174
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 21:21:56 -0400
Received: from gescom.nrt.redhat.com (vpn-198-9.nrt.redhat.com [10.64.198.9])
	by pobox.nrt.redhat.com (8.13.1/8.13.1) with ESMTP id m3U1LsZf007500
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 10:21:54 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found some parts inline function dst_metric_locked should be used but
not.
The following patch fixes these.

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

include/net/ip.h | 2 +-
net/ipv4/route.c | 2 +-
2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 6d7bcd5..3b40bc2 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -210,7 +210,7 @@ int ip_dont_fragment(struct sock *sk, struct
dst_entry *dst)
{
return (inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
(inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
- !(dst_metric(dst, RTAX_LOCK)&(1<<RTAX_MTU))));
+ !(dst_metric_locked(dst, RTAX_MTU))));
}

extern void __ip_select_ident(struct iphdr *iph, struct dst_entry *dst,
int more);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ce25a13..2fd69b5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1607,7 +1607,7 @@ static void rt_set_nexthop(struct rtable *rt,
struct fib_result *res, u32 itag)
sizeof(rt->u.dst.metrics));
if (fi->fib_mtu == 0) {
rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
- if (rt->u.dst.metrics[RTAX_LOCK-1] & (1 << RTAX_MTU) &&
+ if (dst_metric_locked(&rt->u.dst, RTAX_MTU) &&
rt->rt_gateway != rt->rt_dst &&
rt->u.dst.dev->mtu > 576)
rt->u.dst.metrics[RTAX_MTU-1] = 576;



