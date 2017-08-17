From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/7] Covscan: Don't access garbage
Date: Thu, 17 Aug 2017 19:09:24 +0200
Message-ID: <20170817170931.24302-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57189 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751665AbdHQRMp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which resolve situations where
garbage might be read, either due to missing initialization of
variables or accessing data which went out of scope.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (7):
  ipaddress: Make buffer for filter.flushb static
  ipaddress: Avoid accessing uninitialized variable lcl
  iplink_can: Prevent overstepping array bounds
  ipmaddr: Avoid accessing uninitialized data
  ss: Use C99 initializer in netlink_show_one()
  netem/maketable: Check return value of fstat()
  tc/q_multiq: Don't pass garbage in TCA_OPTIONS

 ip/ipaddress.c    |  4 ++--
 ip/iplink_can.c   |  4 ++--
 ip/ipmaddr.c      |  2 +-
 misc/ss.c         | 13 +++++++------
 netem/maketable.c |  4 ++--
 tc/q_multiq.c     |  2 +-
 6 files changed, 15 insertions(+), 14 deletions(-)

-- 
2.13.1
