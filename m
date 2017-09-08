From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 0/2] malloc correct buff at run time
Date: Fri,  8 Sep 2017 18:14:55 +0800
Message-ID: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37253 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdIHKPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 06:15:32 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so1126354pgn.4
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 03:15:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit 72b365e8e0fd ("libnetlink: Double the dump buffer size") and
460c03f3f3cc ("iplink: double the buffer size also in iplink_get()"), we
extend the buffer size to avoid truncated message with large numbers of
VFs. But just as Michal said, this is not future-proof since the NIC
number is increasing. We have customer even has 220+ VFs now.

This is not make sense to hard code the buffer and increase it all the time.
So let's just malloc the correct buff size at run time.

I'm not sure what init size would be suitable, so I keep use the original
size. I have tried with a small size like 1024, and it also works.

I tested with most ip cmds and all looks good.

Hangbin Liu (2):
  lib/libnetlink: re malloc buff if size is not enough
  lib/libnetlink: update rtnl_talk to support malloc buff at run time

 bridge/fdb.c         |   2 +-
 bridge/link.c        |   2 +-
 bridge/mdb.c         |   2 +-
 bridge/vlan.c        |   2 +-
 genl/ctrl.c          |  14 +++---
 include/libnetlink.h |   6 +--
 ip/ipaddress.c       |   5 ++-
 ip/ipaddrlabel.c     |   4 +-
 ip/ipfou.c           |   4 +-
 ip/ipila.c           |   4 +-
 ip/ipl2tp.c          |   8 ++--
 ip/iplink.c          |  28 +++++-------
 ip/iplink_vrf.c      |  24 ++++-------
 ip/ipmacsec.c        |   2 +-
 ip/ipneigh.c         |   2 +-
 ip/ipnetns.c         |  13 +++---
 ip/ipntable.c        |   2 +-
 ip/iproute.c         |  20 +++++----
 ip/iprule.c          |   7 +--
 ip/ipseg6.c          |   7 +--
 ip/iptoken.c         |   2 +-
 ip/link_gre.c        |   7 +--
 ip/link_gre6.c       |   7 +--
 ip/link_ip6tnl.c     |   7 +--
 ip/link_iptnl.c      |   7 +--
 ip/link_vti.c        |   7 +--
 ip/link_vti6.c       |   7 +--
 ip/tcp_metrics.c     |   7 +--
 ip/xfrm_policy.c     |  22 +++++-----
 ip/xfrm_state.c      |  25 ++++++-----
 lib/libgenl.c        |   5 ++-
 lib/libnetlink.c     | 118 ++++++++++++++++++++++++++++++++-------------------
 misc/ss.c            |   2 +-
 tc/m_action.c        |   9 ++--
 tc/tc_class.c        |   2 +-
 tc/tc_filter.c       |   7 +--
 tc/tc_qdisc.c        |   2 +-
 37 files changed, 217 insertions(+), 184 deletions(-)

-- 
2.5.5
