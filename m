From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not cache align timewait sockets
Date: Fri, 10 Apr 2015 06:07:18 -0700
Message-ID: <1428671238.25985.306.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37537 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511AbbDJNHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 09:07:21 -0400
Received: by igblo3 with SMTP id lo3so16770619igb.0
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 06:07:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With recent adoption of skc_cookie in struct sock_common,
struct tcp_timewait_sock size increased from 192 to 200 bytes
on 64bit arches. SLAB rounds then to 256 bytes.

It is time to drop SLAB_HWCACHE_ALIGN constraint for twsk_slab.

This saves about 12 MB of memory on typical configuration reaching
262144 timewait sockets, and has no noticeable impact on performance.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 654e38a9975948f981f35716e7b9eac8569f0f93..e891bcf325ca759c9b7498f29ec76aa946198d5e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2799,8 +2799,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 				kmem_cache_create(prot->twsk_prot->twsk_slab_name,
 						  prot->twsk_prot->twsk_obj_size,
 						  0,
-						  SLAB_HWCACHE_ALIGN |
-							prot->slab_flags,
+						  prot->slab_flags,
 						  NULL);
 			if (prot->twsk_prot->twsk_slab == NULL)
 				goto out_free_timewait_sock_slab_name;
