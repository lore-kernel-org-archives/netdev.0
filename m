From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next v4 0/3] Completed requested changes
Date: Tue, 31 Oct 2017 14:14:28 -0400
Message-ID: <1509473668-4091-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        oss-drivers@netronome.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:45901 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932341AbdJaSOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:14:39 -0400
Received: by mail-qk0-f194.google.com with SMTP id f199so21662122qke.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:14:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

Modified the netronome drivers (flower action) to use the VLAN helper functions
instead of dereferencing the structure directly. This is required for the VLAN
action patch.

Could you please review?

Here're the changes:
v2: Fixed all helper functions to use RCU (rtnl_dereference) - Eric, Jamal
v2: Fixed indentation, extra line nits - Jamal, Jiri
v2: Moved rcu_head to the end of the struct - Jiri
v2: Re-formatted locals to reverse-christmas-tree - Jiri
v2: Removed mismatched spin_lock() - Cong
v2: Removed spin_lock_bh() in tcf_vlan_init, rtnl_dereference() should
    suffice - Cong, Jiri
v4: Modified the nfp flower action code to use the VLAN helper functions
    instead of referencing the structure directly. Isolated this into a
    separate patch - Pieter Jansen

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Manish Kurup <manish.kurup@verizon.com>

Manish Kurup (3):
  net sched act_vlan: Change stats update to use per-core stats
  drivers net ethernet netronome nfp flower: netronome nfp flower action
  net sched act_vlan: VLAN action rewrite to use RCU lock/unlock and
    update

 drivers/net/ethernet/netronome/nfp/flower/action.c |  5 +-
 include/net/tc_act/tc_vlan.h                       | 46 +++++++++++---
 net/sched/act_vlan.c                               | 71 ++++++++++++++--------
 3 files changed, 84 insertions(+), 38 deletions(-)

-- 
2.7.4
