From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 0/5] net_sched: Add support for IFE action
Date: Tue, 23 Feb 2016 07:49:15 -0500
Message-ID: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	john.fastabend@gmail.com, dj@verizon.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33870 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbcBWMtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 07:49:31 -0500
Received: by mail-io0-f171.google.com with SMTP id 9so213245549iom.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 04:49:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>


As agreed at netconf in Seville, here's the patch finally (1 year
was just too long to wait).
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

Jamal Hadi Salim (5):
  introduce IFE action
  Support to encoding decoding skb mark on IFE action
  Support to encoding decoding skb prio on IFE action
  Support to encoding decoding skb hashid on IFE action
  Support to encoding decoding skb queue map on IFE action

 include/net/tc_act/tc_ife.h        |  60 +++
 include/uapi/linux/tc_act/tc_ife.h |  38 ++
 net/sched/Kconfig                  |  32 ++
 net/sched/Makefile                 |   5 +
 net/sched/act_ife.c                | 865 +++++++++++++++++++++++++++++++++++++
 net/sched/act_meta_mark.c          |  79 ++++
 net/sched/act_meta_qmap.c          |  96 ++++
 net/sched/act_meta_skbhash.c       |  84 ++++
 net/sched/act_meta_skbprio.c       |  76 ++++
 9 files changed, 1335 insertions(+)
 create mode 100644 include/net/tc_act/tc_ife.h
 create mode 100644 include/uapi/linux/tc_act/tc_ife.h
 create mode 100644 net/sched/act_ife.c
 create mode 100644 net/sched/act_meta_mark.c
 create mode 100644 net/sched/act_meta_qmap.c
 create mode 100644 net/sched/act_meta_skbhash.c
 create mode 100644 net/sched/act_meta_skbprio.c

-- 
1.9.1
