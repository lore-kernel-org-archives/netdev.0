From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH net 0/2] net: revert lib/percpu_counter API for
 fragmentation mem accounting
Date: Fri, 01 Sep 2017 11:26:03 +0200
Message-ID: <150425790711.22227.12264977619066874632.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, Florian Westphal <fw@strlen.de>,
        liujian56@huawei.com, Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751457AbdIAJ0I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 05:26:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a bug in fragmentation codes use of the percpu_counter API,
that can cause issues on systems with many CPUs, above 24 CPUs.

After much consideration and different attempts at solving the API
usage.  The conclusion is to revert to the simple atomic_t API instead.

The ratio between batch size and threshold size make it a bad use-case
for the lib/percpu_counter API.  As using the correct API calls will
unfortunately cause systems with many CPUs to always execute an
expensive sum across all CPUs. Plus the added complexity is not worth it.

---

Jesper Dangaard Brouer (2):
      Revert "net: use lib/percpu_counter API for fragmentation mem accounting"
      Revert "net: fix percpu memory leaks"


 include/net/inet_frag.h                 |   35 ++++++++-----------------------
 net/ieee802154/6lowpan/reassembly.c     |   11 +++-------
 net/ipv4/inet_fragment.c                |    4 +---
 net/ipv4/ip_fragment.c                  |   12 +++--------
 net/ipv6/netfilter/nf_conntrack_reasm.c |   12 +++--------
 net/ipv6/reassembly.c                   |   12 +++--------
 6 files changed, 22 insertions(+), 64 deletions(-)
