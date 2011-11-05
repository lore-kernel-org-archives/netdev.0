From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH/RFC 00/11] HFSC patches
Date: Sat,  5 Nov 2011 03:32:46 +0100
Message-ID: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:38979 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab1KECdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those are most of the patches I've been sitting on for a while. For the most
part they are either small corrections or simplifications (marked with s) - but
there are also some new things (marked with !), the most interesting being #8
probably.

All changes are richly commented in respective commit messages. I've been using
them for a while - so unless I missed some subtlety, all should be fine.

Apart from these, there's still one subtle thing to do w.r.t. cl_cvtmin (during
init_vf(), as this value is lagged relatively to the situation at the time of
enqueue).

On a side note, I was thinking about something like hfsc-strict or so - where
[uplink] interface could be upperlimited on hfsc qdisc level, but all the class
upperlimit would be otherwise gone. Not sure if anyone would be even interested
in something like that at all.


Michal Soltys (11):
  sch_hfsc.c: update_d() fixup
  sch_hfsc.c: go passive after cl_vt update in update_vf()
  sch_hfsc.c: rtsc_min() convex/convex case fixup
s sch_hfsc.c: remove initial check in vttree_get_minvt() (optional)
s sch_hfsc.c: don't subtract from cl_vtoff and cl_cvtoff
s sch_hfsc.c: seg_y2x(), rtsc_y2x(), hfsc_change_class() minor changes
s sch_hfsc.c: make cl_vt keep all periods in itself
! sch_hfsc.c: update speed table, add explanations, increase accuracy
s sch_hfsc.c: split update_vf()
! sch_hfsc.c: make sure classes are able to use 1st segment on fresh backlog period
s sch_hfsc.c: remove cl_vtadj, shift virtual curve instead

 net/sched/sch_hfsc.c |  373 +++++++++++++++++++++++++++-----------------------
 1 files changed, 203 insertions(+), 170 deletions(-)

-- 
1.7.7.1
