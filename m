From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 0/2] Fixes for tunnel checksum and segmentation offloads
Date: Mon, 02 May 2016 09:25:04 -0700
Message-ID: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, ogerlitz@mellanox.com, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35441 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997AbcEBQZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:25:07 -0400
Received: by mail-pa0-f47.google.com with SMTP id iv1so75974870pac.2
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:25:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is a subset of patches I had submitted for net-next.  I
plan to drop these two patches from the v3 of "Fix Tunnel features and
enable GSO partial for several drivers" and I am instead submitting them
for net since these are truly fixes and likely will need to be backported
to stable branches.

This series addresses 2 specific issues.  The first is that we could
request TSO on a v4 inner header while not supporting checksum offload of
the outer IPv6 header.  The second is that we could request an IPv6 inner
checksum offload without validating that we could actually support an inner
IPv6 checksum offload.

---

Alexander Duyck (2):
      net: Disable segmentation if checksumming is not supported
      vxlan: Add checksum check to the features check function


 include/linux/if_ether.h |    5 +++++
 include/net/vxlan.h      |    4 +++-
 net/core/dev.c           |    2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)
