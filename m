From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 0/3] sched: act: ife: UAPI checks and performance tweaks
Date: Wed, 11 Oct 2017 17:16:05 -0400
Message-ID: <20171011211608.22692-1-aring@mojatatu.com>
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45004 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdJKVQj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:16:39 -0400
Received: by mail-io0-f193.google.com with SMTP id m16so3302792iod.1
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:16:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch series contains at first a patch which adds a check for
IFE_ENCODE and IFE_DECODE when a ife act gets created or updated and adding
handling of these cases only inside the act callback only.

The second patch use per-cpu counters and move the spinlock around so that
the spinlock is less being held in act callback.

The last patch use rcu for update parameters and also move the spinlock for
the same purpose as in patch 2.

Notes:
 - There is still a spinlock around for protecting the metalist and a
   rw-lock for another list. Should be migrated to a rcu list, ife
   possible.

 - I use still dereference in dump callback, so I think what I didn't
   got was what happened when rcu_assign_pointer will do when rcu read
   lock is held. I suppose the pointer will be updated, then we don't
   have any issue here.

Alexander Aring (3):
  sched: act: ife: move encode/decode check to init
  sched: act: ife: migrate to use per-cpu counters
  sched: act: ife: update parameters via rcu handling

 include/net/tc_act/tc_ife.h |  10 +++-
 net/sched/act_ife.c         | 135 +++++++++++++++++++++++++-------------------
 2 files changed, 86 insertions(+), 59 deletions(-)

-- 
2.11.0
