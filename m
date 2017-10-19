From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v3 0/2] ipv6: fixes for RTF_CACHE entries
Date: Thu, 19 Oct 2017 16:07:09 +0200
Message-ID: <cover.1508421311.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754638AbdJSOII (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 10:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series addresses 2 different but related issues with RTF_CACHE introduced
by the recent refactory.

patch 1 restore the gc timer for such routes
patch 2 removes the aged out dst from the fib tree, properly coping with pMTU
routes

v1 -> v2:
 - dropped the  for ip route show cache
 - avoid touching dst.obsolete when the dst is aged out

v2 -> v3:
 - take care of pMTU exceptions

Paolo Abeni (2):
  ipv6: start fib6 gc on RTF_CACHE dst creation
  ipv6: remove from fib tree aged out RTF_CACHE dst

 net/ipv6/route.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

-- 
2.13.6
