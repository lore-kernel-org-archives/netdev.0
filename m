From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v2 0/3] update ifstat for new stats
Date: Thu, 15 Dec 2016 15:00:42 +0200
Message-ID: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        jiri@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37104 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756056AbcLOM63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 07:58:29 -0500
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
v1->v2:
 - change from using RTM_GETSTATS always to using it only for extended
   stats.
 - Add 64bits extended stats type.

Nogah Frankel (3):
  ifstat: Add extended statistics to ifstat
  ifstat: Add 64 bits based stats to extended statistics
  ifstat: Add "sw only" extended statistics to ifstat

 misc/ifstat.c | 165 ++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 150 insertions(+), 15 deletions(-)

-- 
2.4.3
