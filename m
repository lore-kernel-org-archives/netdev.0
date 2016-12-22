From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v3 0/4] update ifstat for new stats
Date: Thu, 22 Dec 2016 18:23:11 +0200
Message-ID: <1482423795-6531-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, ogerlitz@mellanox.com, jiri@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60666 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965524AbcLVQVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously stats were gotten by RTM_GETLINK which returns 32 bits based
statistics. It supports only one type of stats.
Lately, a new method to get stats was added - RTM_GETSTATS. It supports
ability to choose stats type. The basic stats were changed from 32 bits
based to 64 bits based.

This patchset adds ifstat the ability to get extended stats by this
method. Its adds two types of extended stats:
64bits - the same as the "normal" stats but get the stats from the cpu
in 64 bits based struct.
SW - for packets that hit cpu.

---
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
  ifstat: Add 64 bits based stats to extended statistics
  ifstat: Add "sw only" extended statistics to ifstat

 misc/ifstat.c | 171 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 153 insertions(+), 18 deletions(-)

-- 
2.4.3
