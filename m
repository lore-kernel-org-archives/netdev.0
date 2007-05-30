From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 11:40:55 +0200 (MEST)
Message-ID: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33825 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbXE3Jk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 05:40:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One good thing about ESFQ is the more flexible flow classification, but
I don't like the concept of having a set of selectable hash functions
very much.

These patches change SFQ to allow attaching external classifiers and add
a new "flow" classifier that allows to classify flows based on an arbitary
combination of pre-defined keys. Its probably not the fastest classifier
when used with multiple keys, but frankly, I don't think speed is very
important in most situations where the current SFQ implementation is used.

It currently does not support perturbation, I didn't want to move this into
the classifier, so I need to think about a way to handle it within SFQ.


Some examples:

# behave identical to internal SFQ hash
tc filter add ... flow baseclass x:1 classes 1024 \
		       keys src,dst,proto-src,proto-dst

# the same, but based on source address/port before NAT
tc filter add ... flow baseclass x:1 classes 1024 \
		       keys nfct-src,dst,nfct-proto-src,proto-dst

# classify based on UID
tc filter add ... flow baseclass x:1 classes 1024 \
		       keys sk-uid


and so on .. check out the iproute help text for the full set of supported
keys.


Comments welcome.


 include/linux/pkt_cls.h |   37 +++
 net/sched/Kconfig       |   11 
 net/sched/Makefile      |    1 
 net/sched/cls_flow.c    |  570 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/sched/sch_sfq.c     |   98 +++++++-
 5 files changed, 713 insertions(+), 4 deletions(-)

Patrick McHardy (2):
      [NET_SCHED]: sch_sfq: add support for external classifiers
      [NET_SCHED]: Add flow classifier
