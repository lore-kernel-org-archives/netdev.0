From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next 0/2] Completed requested changes
Date: Thu, 26 Oct 2017 15:11:46 -0400
Message-ID: <1509045106-31808-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:46047 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932442AbdJZTMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 15:12:00 -0400
Received: by mail-qt0-f195.google.com with SMTP id p1so5689974qtg.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 12:12:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

    I've made all requested changes to the act_vlan TC action, tested them, and
here's the new changeset. Could you please review and let me know
if I can commit this? Thanks a lot!

Here're the fixes:
*> Fixed all helper functions to use RCU (rtnl_dereference).
*> Fixed indentation, extra line nits
*> Moved rcu_head to the end of the struct
*> Converted to reverse-christmas-tree
*> Removed mismatched spin_lock()
*> Removed spin_lock_bh() in tcf_vlan_init, rtnl_dereference() should suffice.

Thanks for all the comments!
 

Manish Kurup (2):
  net sched act_vlan: Change stats update to use per-core stats
  net sched act_vlan: VLAN action rewrite to use RCU lock/unlock and
    update

 include/net/tc_act/tc_vlan.h | 46 ++++++++++++++++++++++------
 net/sched/act_vlan.c         | 71 ++++++++++++++++++++++++++++----------------
 2 files changed, 82 insertions(+), 35 deletions(-)

-- 
2.7.4
