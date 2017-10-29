From: Manish Kurup <kurup.manish@gmail.com>
Subject: [PATCH net-next v3 0/2] Completed requested changes
Date: Sun, 29 Oct 2017 04:46:52 -0400
Message-ID: <1509266812-16909-1-git-send-email-manish.kurup@verizon.com>
Cc: aring@mojatatu.com, mrv@mojatatu.com, kurup.manish@gmail.com,
        Manish Kurup <manish.kurup@verizon.com>
To: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        oss-drivers@netronome.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:51896 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750928AbdJ2IrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 04:47:12 -0400
Received: by mail-qt0-f193.google.com with SMTP id h4so13034743qtk.8
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 01:47:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

The kbuild robot detected an issue with building the netronome drivers (flower
action). Fixed them to use the VLAN helper functions instead of dereferencing
the structure directly.

Could you please review?

Here're the changes:
v2: Fixed all helper functions to use RCU (rtnl_dereference) - Eric, Jamal
v2: Fixed indentation, extra line nits - Jamal, Jiri
v2: Moved rcu_head to the end of the struct - Jiri
v2: Re-formatted locals to reverse-christmas-tree - Jiri
v2: Removed mismatched spin_lock() - Cong
v2: Removed spin_lock_bh() in tcf_vlan_init, rtnl_dereference() should
    suffice - Cong, Jiri
v3: Fixed a build break issue with nxp flower action. Modified the NXP flower
    action code to use the VLAN helper functions instead of referencing the
    structure directly. Found by kbuild robot.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Manish Kurup <manish.kurup@verizon.com>

Manish Kurup (2):
  net sched act_vlan: Change stats update to use per-core stats
  net sched act_vlan: VLAN action rewrite to use RCU lock/unlock and
    update

 drivers/net/ethernet/netronome/nfp/flower/action.c |  5 +-
 include/net/tc_act/tc_vlan.h                       | 46 +++++++++++---
 net/sched/act_vlan.c                               | 71 ++++++++++++++--------
 3 files changed, 84 insertions(+), 38 deletions(-)

-- 
2.7.4
