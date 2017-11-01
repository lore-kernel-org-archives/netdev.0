From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 0/2] net_sched: fix a use-after-free for tc actions
Date: Wed,  1 Nov 2017 10:23:48 -0700
Message-ID: <20171101172350.12842-1-xiyou.wangcong@gmail.com>
Cc: lucasb@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:49719 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754632AbdKARYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:24:01 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so2455280pfe.6
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:24:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a use-after-free reported by Lucas
and closes potential races too.

Please see each patch for details.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Cong Wang (2):
  net_sched: acquire RTNL in tc_action_net_exit()
  net_sched: hold netns refcnt for each action

 include/net/act_api.h      | 6 +++++-
 net/sched/act_api.c        | 4 ++++
 net/sched/act_bpf.c        | 2 +-
 net/sched/act_connmark.c   | 2 +-
 net/sched/act_csum.c       | 2 +-
 net/sched/act_gact.c       | 2 +-
 net/sched/act_ife.c        | 2 +-
 net/sched/act_ipt.c        | 4 ++--
 net/sched/act_mirred.c     | 2 +-
 net/sched/act_nat.c        | 2 +-
 net/sched/act_pedit.c      | 2 +-
 net/sched/act_police.c     | 2 +-
 net/sched/act_sample.c     | 2 +-
 net/sched/act_simple.c     | 2 +-
 net/sched/act_skbedit.c    | 2 +-
 net/sched/act_skbmod.c     | 2 +-
 net/sched/act_tunnel_key.c | 2 +-
 net/sched/act_vlan.c       | 2 +-
 18 files changed, 26 insertions(+), 18 deletions(-)

-- 
2.13.0
