From: Michal Kazior <michal.kazior@tieto.com>
Subject: [PATCH 0/2] codel: make it reuseable beyond qdiscs
Date: Fri, 22 Apr 2016 14:15:57 +0200
Message-ID: <1461327359-21646-1-git-send-email-michal.kazior@tieto.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
	Michal Kazior <michal.kazior@tieto.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34456 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbcDVMOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 08:14:10 -0400
Received: by mail-lb0-f170.google.com with SMTP id b1so37693798lbi.1
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 05:14:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

There's an ongoing effort in fixing wireless
bufferbloat. As part of that fq_codel is being
ported into mac80211. To prevent code duplication
codel.h needs to be slightly modified before it
can be used in mac80211 (or other drivers FWIW).

For more background please see:

  https://www.spinics.net/lists/linux-wireless/msg149976.html


Michal Kazior (2):
  codel: generalize the implementation
  codel: split into multiple files

 include/net/codel.h       | 217 +--------------------------------------
 include/net/codel_impl.h  | 255 ++++++++++++++++++++++++++++++++++++++++++++++
 include/net/codel_qdisc.h |  73 +++++++++++++
 net/sched/sch_codel.c     |  22 +++-
 net/sched/sch_fq_codel.c  |  21 +++-
 5 files changed, 368 insertions(+), 220 deletions(-)
 create mode 100644 include/net/codel_impl.h
 create mode 100644 include/net/codel_qdisc.h

-- 
2.1.4
