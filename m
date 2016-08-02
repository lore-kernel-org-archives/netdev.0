From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH net-next v2 0/2] HFSC patches
Date: Wed,  3 Aug 2016 00:44:53 +0200
Message-ID: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:33261 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958AbcHBWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 18:45:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:

- in the first patch's commit message, reference old patch using kernel.org's
  historical tree (instead of using gmane)
- in the second patch we just remove variable

Notes regarding patch #1/2:

This patch syncs virtual times with fair service curve and fixes a very old
subtle bug.

The detailed explanation is in the commit message. Additionally
I've made an illustration to help understand the issue better:

http://imgur.com/a/N8uMC

See the example at the bottom of the commit message - Am1_3 and Am2_3 is what
should happen with such queue setup, Am1_3real and Am2_3real is what actually
happens due to rtsc_min() calculating minimum from corrected and uncorrected
curves.

Michal Soltys (2):
  net/sched/sch_hfsc.c: keep fsc and virtual times in sync; fix an old
    bug
  net/sched/sch_hfsc.c: remove unused cl_myfadj

 net/sched/sch_hfsc.c | 51 ++++++++++++++-------------------------------------
 1 file changed, 14 insertions(+), 37 deletions(-)

-- 
2.1.3
