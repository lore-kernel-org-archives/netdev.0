From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v5 0/4] update ifstat for new stats
Date: Thu, 26 Jan 2017 14:44:37 +0200
Message-ID: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51709 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752020AbdAZMnC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:43:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously stats were gotten by RTM_GETLINK which returns 32 bits based
statistics. It supports only one type of stats.
Lately, a new method to get stats was added - RTM_GETSTATS. It supports
ability to choose stats type. The basic stats were changed from 32 bits
based to 64 bits based.

This patchset adds ifstat the ability to get extended stats (xstats) by
this method. Its adds xstat of cpu_hits - for packets that hit cpu.

---
v4->v5:
 - remove patch 3/4 that added 64 based "normal" stats
 - add a new patch 4/4 that updates ifstat man page

v3->v4:
- patch 2/4:
 - change xstat name read to avoid redundant copy.
 - delete extra line
- patch 4/4:
 - change xstat name.

v2->v3:
- patch 1/4:
 - add a new patch to reorder includes in misc/ifstat.c
- patch 2/4: (previously 1/3)
 - fix typos.
 - change error print to use fprintf.

v1->v2:
 - change from using RTM_GETSTATS always to using it only for extended
   stats.
 - Add 64bits extended stats type.

Nogah Frankel (4):
  ifstat: Includes reorder
  ifstat: Add extended statistics to ifstat
  ifstat: Add "sw only" extended statistics to ifstat
  ifstat: Add xstat to ifstat man page

 man/man8/Makefile |   3 +-
 man/man8/ifstat.8 |  12 +++-
 misc/ifstat.c     | 168 ++++++++++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 163 insertions(+), 20 deletions(-)

-- 
2.4.3
