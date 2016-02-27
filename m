From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next-2.6 v4 0/3] net_sched: Add support for IFE action
Date: Sat, 27 Feb 2016 08:08:53 -0500
Message-ID: <1456578536-17732-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:32792 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756590AbcB0NJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 08:09:14 -0500
Received: by mail-ig0-f178.google.com with SMTP id y8so55185877igp.0
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 05:09:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

As agreed at netconf in Seville, here's the patch finally (1 year
was just too long to wait for an ethertype. Now we are just going
have the user configure one).
Described in netdev01 paper:
            "Distributing Linux Traffic Control Classifier-Action Subsystem"
             Authors: Jamal Hadi Salim and Damascene M. Joachimpillai

The original motivation and deployment of this work was to horizontally
scale packet processing at scope of a chasis or rack. This means one
could take a tc policy and split it across machines connected over
L2. The paper refers to this as "pipeline stage indexing". Other
use cases which evolved out of the original intent include but are
not limited to carrying OAM information, carrying exception handling
metadata, carrying programmed authentication and authorization information,
encapsulating programmed compliance information, service IDs etc.
Read the referenced paper for more details.

The architecture allows for incremental updates for new metadatum support
to cover different use cases.
This patch set includes support for basic skb metadatum.
Followup patches will have more examples of metadata and other features.

v4 changes:
Integrate more feedback from Cong 

v3 changes:
Integrate with the new namespace changes 
Remove skbhash and queue mapping metadata (but keep their claim for ids)
Integrate feedback from Cong 
Integrate feedback from Daniel

v2 changes:
Remove module option for an upper bound of metadata
Integrate feedback from Cong 
Integrate feedback from Daniel

Jamal Hadi Salim (3):
  introduce IFE action
  Support to encoding decoding skb mark on IFE action
  Support to encoding decoding skb prio on IFE action

 include/net/tc_act/tc_ife.h        |  61 +++
 include/uapi/linux/tc_act/tc_ife.h |  38 ++
 net/sched/Kconfig                  |  22 +
 net/sched/Makefile                 |   3 +
 net/sched/act_ife.c                | 883 +++++++++++++++++++++++++++++++++++++
 net/sched/act_meta_mark.c          |  79 ++++
 net/sched/act_meta_skbprio.c       |  76 ++++
 7 files changed, 1162 insertions(+)
 create mode 100644 include/net/tc_act/tc_ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_ife.h
 create mode 100644 net/sched/act_ife.c
 create mode 100644 net/sched/act_meta_mark.c
 create mode 100644 net/sched/act_meta_skbprio.c

-- 
1.9.1
