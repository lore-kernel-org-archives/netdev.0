From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 0/6] Covscan: Fixes for string termination
Date: Thu, 24 Aug 2017 11:51:44 +0200
Message-ID: <20170824095150.5469-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57159 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751768AbdHXJwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 dealing with code potentially
leaving string buffers unterminated. This does not include situations
where it happens for parsed interface names since an overall solution
was attempted for that and it's state is still unclear due to lack of
feedback from upstream.

Changes since v3:
- Dropped patch 2 since upstream discussion in v3 is not conclusive yet.

Phil Sutter (6):
  ipntable: Avoid memory allocation for filter.name
  lib/fs: Fix format string in find_fs_mount()
  lib/inet_proto: Review inet_proto_{a2n,n2a}()
  lnstat_util: Simplify alloc_and_open() a bit
  tc/m_xt: Fix for potential string buffer overflows
  lib/ll_map: Choose size of new cache items at run-time

 ip/ipntable.c      |  6 +++---
 lib/fs.c           |  2 +-
 lib/inet_proto.c   | 24 +++++++++++++-----------
 lib/ll_map.c       |  4 ++--
 misc/lnstat_util.c |  7 ++-----
 tc/m_xt.c          |  7 ++++---
 6 files changed, 25 insertions(+), 25 deletions(-)

-- 
2.13.1
