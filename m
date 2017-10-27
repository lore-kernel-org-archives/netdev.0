From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next 0/2] Completed requested changes - RESEND with ACKS
Date: Fri, 27 Oct 2017 11:09:56 -0400
Message-ID: <1509116996-8326-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:48891 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbdJ0PKG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:10:06 -0400
Received: by mail-qk0-f196.google.com with SMTP id d67so8715096qkg.5
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 08:10:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

Apologies for the resend, but wanted to add the acks by Jamal and Jiri for this
review contingent upon the changes that are made herein. Had forgotten to add
them the first time around.

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
 
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Manish Kurup <manish.kurup@verizon.com>

Manish Kurup (2):
  net sched act_vlan: Change stats update to use per-core stats
  net sched act_vlan: VLAN action rewrite to use RCU lock/unlock and
    update

 include/net/tc_act/tc_vlan.h | 46 ++++++++++++++++++++++------
 net/sched/act_vlan.c         | 71 ++++++++++++++++++++++++++++----------------
 2 files changed, 82 insertions(+), 35 deletions(-)

-- 
2.7.4
