From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 0/5] HFSC patches, part 1
Date: Thu, 30 Jun 2016 02:26:43 +0200
Message-ID: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50040 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610AbcF3A1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It's revised version of part of the patches I submitted really, really long
time ago (back then I asked Patrick to ignore them as I found some issues
shortly after submitting).

Anyway this is the first set with very simple fixes/changes though some of them
relatively subtle (I tried to do very exhaustive commit messages explaining what
and why with those).

The patches are against net-next tree.

The second set will be heavier - or rather with more complex explanations, among those I have:

- a fix to subtle issue introduced in
  http://permalink.gmane.org/gmane.linux.kernel.commits.2-4/8281
  along with simplifying related stuff
- update times to 96 bits (which allows to "just" use 32 bit shifts and
  improves curve definition accuracy at more extreme low/high speeds)
- add curve "merging" instead of just selecting in convex case (computations
  mirror those from concave intersection)

But these are eventually for later.

Michal Soltys (5):
  net/sched/sch_hfsc.c: handle corner cases where head may change invalidating calculated deadline
  net/sched/sch_hfsc.c: add unlikely() in qdisc_peek_len()
  net/sched/sch_hfsc.c: remove leftover dlist and droplist
  net/sched/sch_hfsc.c: go passive after vt update
  net/sched/sch_hfsc.c: anchor virtual curve at proper vt in hfsc_change_fsc()

 net/sched/sch_hfsc.c | 54 ++++++++++++++++++++++++++--------------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

-- 
2.1.3
