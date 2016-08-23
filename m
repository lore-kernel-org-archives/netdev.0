From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: get rid of SLAB_DESTROY_BY_RCU allocations
Date: Tue, 23 Aug 2016 09:57:51 -0700
Message-ID: <1471971471.14381.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35187 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752308AbcHWQ6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 12:58:32 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so10180759pad.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 09:57:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
we do not need this special allocation mode anymore, even if it is
harmless.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note that sk_prot_clear_portaddr_nulls() is no longer needed,
but I will send a separate patch targeting net-next.

 net/ipv4/udp.c     |    1 -
 net/ipv4/udplite.c |    1 -
 net/ipv6/udp.c     |    1 -
 net/ipv6/udplite.c |    1 -
 4 files changed, 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8f5f7f6026f7fd8d157a2855334bf9cdf453cdee..f4b0d74a56973164ef3de8e9f15c9968a439f83b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2217,7 +2217,6 @@ struct proto udp_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 3b3efbda48e13941b35388238508706844c043aa..2eea073e27efa13a86d6c6107426435ae7ddb18d 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -55,7 +55,6 @@ struct proto 	udplite_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,
 	.obj_size	   = sizeof(struct udp_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udp_setsockopt,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 81e2f98b958d4d42d137a4ae2d71c4c7217c71d6..19ac3a1c308dbfacf136e262dbab27ad280cfdcd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1460,7 +1460,6 @@ struct proto udpv6_prot = {
 	.sysctl_wmem	   = &sysctl_udp_wmem_min,
 	.sysctl_rmem	   = &sysctl_udp_rmem_min,
 	.obj_size	   = sizeof(struct udp6_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udp_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 9cf097e206e931c6e3c184f22b8adcabedc4c03a..fd6ef414899bea824ce26c2e738f4e96aa8af464 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -50,7 +50,6 @@ struct proto udplitev6_prot = {
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v6_get_port,
 	.obj_size	   = sizeof(struct udp6_sock),
-	.slab_flags	   = SLAB_DESTROY_BY_RCU,
 	.h.udp_table	   = &udplite_table,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_udpv6_setsockopt,
