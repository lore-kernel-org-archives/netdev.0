From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v4 0/4] update ifstat for new stats
Date: Thu, 12 Jan 2017 15:49:47 +0200
Message-ID: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roszenrami@gmail.com,
        roopa@cumulusnetworks.com, jiri@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44273 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750819AbdALNq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:46:59 -0500
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
cpu_hits - for packets that hit cpu.

---
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
  ifstat: Add 64 bits based stats to extended statistics
  ifstat: Add "sw only" extended statistics to ifstat

 misc/ifstat.c | 170 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 152 insertions(+), 18 deletions(-)

-- 
2.4.3
