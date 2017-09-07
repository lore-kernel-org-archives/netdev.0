From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V2 PATCH net-next 0/2] Fixes for XDP_REDIRECT map
Date: Thu, 07 Sep 2017 14:33:08 +0200
Message-ID: <150478756604.28665.6915020425359475729.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56074 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754964AbdIGMdL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 08:33:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This my V2 of catching XDP_REDIRECT and bpf_redirect_map() API usage
that can potentially crash the kernel.  Addressed Daniels feedback in
patch01, and added patch02 which catch and cleanup dangling map
pointers.

I know John and Daniel are working on a more long-term solution, of
recording the bpf_prog pointer together with the map pointer.  I just
wanted to propose these fixes as a stop-gap to the potential crashes.

---

Jesper Dangaard Brouer (2):
      xdp: implement xdp_redirect_map for generic XDP
      xdp: catch invalid XDP_REDIRECT API usage


 include/linux/filter.h     |    1 +
 include/trace/events/xdp.h |    4 ++--
 net/core/dev.c             |    3 +++
 net/core/filter.c          |   39 ++++++++++++++++++++++++++++++++++++---
 4 files changed, 42 insertions(+), 5 deletions(-)
