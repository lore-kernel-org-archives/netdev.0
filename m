From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/6] strlcpy() and strlcat() for iproute2
Date: Fri,  1 Sep 2017 18:52:50 +0200
Message-ID: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44237 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751863AbdIAQxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds my own implementations of strlcpy() and
strlcat() in patch 1 and changes the code to make use of them in the
following patches but the last two: Patch 5 just eliminates a line of
useless code I found while searching for potential users of the
introduced functions, patch 6 sanitizes a call to strncpy() in
misc/lnstat_util.c without using strlcpy() since lnstat is not being
linked against libutil.

I implemented both functions solely based on information in libbsd's man
pages, so they are safe to be released under the GPL.

Phil Sutter (6):
  utils: Implement strlcpy() and strlcat()
  Convert the obvious cases to strlcpy()
  Convert harmful calls to strncpy() to strlcpy()
  ipxfrm: Replace STRBUF_CAT macro with strlcat()
  tc_util: No need to terminate an snprintf'ed buffer
  lnstat_util: Make sure buffer is NUL-terminated

 genl/ctrl.c           |  2 +-
 include/utils.h       |  3 +++
 ip/ipnetns.c          |  3 +--
 ip/iproute_lwtunnel.c |  3 +--
 ip/ipvrf.c            |  5 ++---
 ip/ipxfrm.c           | 21 +++++----------------
 ip/xfrm_state.c       |  2 +-
 lib/bpf.c             |  3 +--
 lib/fs.c              |  3 +--
 lib/inet_proto.c      |  3 +--
 lib/utils.c           | 19 +++++++++++++++++++
 misc/lnstat_util.c    |  3 ++-
 misc/ss.c             |  3 +--
 tc/em_ipset.c         |  3 +--
 tc/tc_util.c          |  1 -
 15 files changed, 40 insertions(+), 37 deletions(-)

-- 
2.13.1
