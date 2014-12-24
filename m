From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2 0/4] Switch network ns w/o 'netns exec' for iproute2 tools
Date: Wed, 24 Dec 2014 23:04:07 +0200
Message-ID: <1419455051-23397-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:51094 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaLXVOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 16:14:19 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so7173730lab.8
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 13:14:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

This series adds new -n[etns] option to ip, tc & bridge tools which
allows to easy and faster switch to specified network namespace. So instead of:

    ip netns exec NETNS { ip | tc | bridge } OBJECT COMMAND

it will be possible do the same by:

    { ip | tc | bridge } -n[etns] NETNS OBJECT COMMAND

I skipped misc tools and will work on them later.

Vadim Kochan (4):
  lib: Add netns_switch func for change network namespace
  ip: Allow to easy change network namespace
  bridge: Allow to easy change network namespace
  tc: Allow to easy change network namespace

 bridge/Makefile     |   4 ++
 bridge/bridge.c     |   7 +++-
 include/namespace.h |  46 +++++++++++++++++++++++
 ip/ip.c             |   7 +++-
 ip/ipnetns.c        | 106 ++--------------------------------------------------
 lib/Makefile        |   6 ++-
 lib/namespace.c     |  86 ++++++++++++++++++++++++++++++++++++++++++
 man/man8/bridge.8   |  23 +++++++++++-
 man/man8/ip.8       |  23 +++++++++++-
 man/man8/tc.8       |  65 ++++++++++++++++++++++++--------
 tc/Makefile         |   5 +++
 tc/tc.c             |   8 +++-
 12 files changed, 262 insertions(+), 124 deletions(-)
 create mode 100644 include/namespace.h
 create mode 100644 lib/namespace.c

-- 
2.1.3
