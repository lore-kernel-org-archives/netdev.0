From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 0/2] illustrate cmpxchg ring for tap/tun and qdisc
Date: Thu, 10 Nov 2016 20:43:47 -0800
Message-ID: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35037 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935011AbcKKEoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 23:44:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cmpxchg ring that could potentially be used to replace the spinlock
variant of skb_array.

Couple comments its missing a resize operator which would need to be added
before it could be a drop in replacement. And although I tested the first
patch with my latest set of qdisc updates the second patch I have not tested
for a bit so it may or may not work but it illustrates the idea at least.

This was derived from the DPDK documentation where there is a description
of the cmpxchg ring presumably used there. It may or may not actually align
with what is done in DPDK implementation I have no idea I didn't look.


---

John Fastabend (2):
      net: use cmpxchg instead of spinlock in ptr rings
      ptr_ring_ll: pop/push multiple objects at once


 include/linux/netdevice.h   |   12 ----
 include/linux/ptr_ring_ll.h |  146 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h   |   32 +++++++++
 net/core/dev.c              |   18 +----
 net/sched/sch_generic.c     |   86 +++++++++++++------------
 5 files changed, 224 insertions(+), 70 deletions(-)
 create mode 100644 include/linux/ptr_ring_ll.h
