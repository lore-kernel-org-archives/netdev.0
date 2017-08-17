From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/7] Covscan: Fixes for string termination
Date: Thu, 17 Aug 2017 19:09:25 +0200
Message-ID: <20170817170932.24659-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43241 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753374AbdHQRMI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 dealing with code potentially
leaving string buffers unterminated. This does not include situations
where it happens for parsed interface names since an overall solution
was attempted for that and it's state is still unclear due to lack of
feedback from upstream.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (7):
  ipntable: Make sure filter.name is NULL-terminated
  xfrm_state: Make sure alg_name is NULL-terminated
  lib/fs: Fix format string in find_fs_mount()
  lib/inet_proto: Make sure destination buffers are NULL-terminated
  lnstat_util: Simplify alloc_and_open() a bit
  tc/m_xt: Fix for potential string buffer overflows
  lib/ll_map: Make sure im->name is NULL-terminated

 ip/ipntable.c      | 3 ++-
 ip/xfrm_state.c    | 3 ++-
 lib/fs.c           | 2 +-
 lib/inet_proto.c   | 9 ++++++---
 lib/ll_map.c       | 4 ++--
 misc/lnstat_util.c | 7 ++-----
 tc/m_xt.c          | 7 ++++---
 7 files changed, 19 insertions(+), 16 deletions(-)

-- 
2.13.1
