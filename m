From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 0/2] limit sk_filter trim to payload
Date: Tue, 12 Jul 2016 18:18:55 -0400
Message-ID: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36039 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbcGLWTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:19:14 -0400
Received: by mail-qk0-f195.google.com with SMTP id q8so840380qke.3
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 15:19:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Sockets can apply a filter to incoming packets to drop or trim them.
Fix two codepaths that call skb_pull/__skb_pull after sk_filter
without checking for packet length.

Reading beyond skb->tail after trimming happens in more codepaths, but
safety of reading in the linear segment is based on minimum allocation
size (MAX_HEADER, GRO_MAX_HEAD, ..).

Willem de Bruijn (2):
  rose: limit sk_filter trim to payload
  dccp: limit sk_filter trim to payload

 include/linux/filter.h |  6 +++++-
 include/net/sock.h     |  8 +++++++-
 net/core/filter.c      | 10 +++++-----
 net/core/sock.c        |  7 ++++---
 net/dccp/ipv4.c        |  2 +-
 net/dccp/ipv6.c        |  2 +-
 net/rose/rose_in.c     |  3 ++-
 7 files changed, 25 insertions(+), 13 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
