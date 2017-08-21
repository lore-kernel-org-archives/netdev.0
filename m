From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 0/7] Covscan: Fixes for string termination
Date: Mon, 21 Aug 2017 15:23:34 +0200
Message-ID: <20170821132341.23118-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58341 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753892AbdHUNX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 09:23:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 dealing with code potentially
leaving string buffers unterminated. This does not include situations
where it happens for parsed interface names since an overall solution
was attempted for that and it's state is still unclear due to lack of
feedback from upstream.

Changes since v2:
- Rebased onto current upstream master branch.
- Replaced patches 1, 4 and 7 by more appropriate ones given feedback
  from v2 review.

Phil Sutter (7):
  ipntable: Avoid memory allocation for filter.name
  xfrm_state: Make sure alg_name is NULL-terminated
  lib/fs: Fix format string in find_fs_mount()
  lib/inet_proto: Review inet_proto_{a2n,n2a}()
  lnstat_util: Simplify alloc_and_open() a bit
  tc/m_xt: Fix for potential string buffer overflows
  lib/ll_map: Choose size of new cache items at run-time

 ip/ipntable.c      |  6 +++---
 ip/xfrm_state.c    |  3 ++-
 lib/fs.c           |  2 +-
 lib/inet_proto.c   | 24 +++++++++++++-----------
 lib/ll_map.c       |  4 ++--
 misc/lnstat_util.c |  7 ++-----
 tc/m_xt.c          |  7 ++++---
 7 files changed, 27 insertions(+), 26 deletions(-)

-- 
2.13.1
