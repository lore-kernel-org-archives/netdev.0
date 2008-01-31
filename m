From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Thu, 31 Jan 2008 18:58:02 +0100 (MET)
Message-ID: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55138 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbYAaR6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:58:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add support for external classifiers to SFQ and add a
new "flow" classifier, which can do hashing based on user-specified
keys or deterministic mapping of keys to classes. Additionally there
is a patch to make the SFQ queues visisble as classes to verify that
the hash is indeed doing something useful and a patch to consifiy
struct tcf_ext_map, which I had queued in the same tree.

Please apply, thanks.


 include/linux/pkt_cls.h   |   50 ++++
 include/linux/pkt_sched.h |    5 +
 include/net/pkt_cls.h     |    6 +-
 net/sched/Kconfig         |   11 +
 net/sched/Makefile        |    1 +
 net/sched/cls_api.c       |    6 +-
 net/sched/cls_basic.c     |    2 +-
 net/sched/cls_flow.c      |  660 +++++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_fw.c        |    2 +-
 net/sched/cls_route.c     |    2 +-
 net/sched/cls_tcindex.c   |    2 +-
 net/sched/cls_u32.c       |    2 +-
 net/sched/sch_sfq.c       |  134 +++++++++-
 13 files changed, 868 insertions(+), 15 deletions(-)
 create mode 100644 net/sched/cls_flow.c

Patrick McHardy (4):
      [NET_SCHED]: Constify struct tcf_ext_map
      [NET_SCHED]: sch_sfq: add support for external classifiers
      [NET_SCHED]: sch_sfq: make internal queues visible as classes
      [NET_SCHED]: Add flow classifier
