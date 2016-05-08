From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 0/6] Fix broken late binding of actions
Date: Sun,  8 May 2016 13:16:00 -0400
Message-ID: <1462727766-28359-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33390 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbcEHRQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 13:16:15 -0400
Received: by mail-io0-f194.google.com with SMTP id x35so16886845ioi.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 10:16:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Some actions were broken in allowing for late binding of actions.
Late binding workflow is as follows:
a) create an action and provide all necessary parameters for it
Optionally provide an index or let the kernel give you one.
Example:
sudo tc actions add action police rate 1kbit burst 90k drop index 1

b) later on bind to the pre-created action from a filter definition
by merely specifying the index.
Example:
sudo tc filter add dev lo parent ffff: protocol ip prio 8 \
u32 match ip src 127.0.0.8/32 flowid 1:8 action police index 1


Jamal Hadi Salim (6):
  tc vlan action fix late binding
  tc ipt action fix late binding
  tc mirred action fix late binding
  tc simple action fix late binding
  tc skbedit action fix late binding
  tc ife action fix late binding

 net/sched/act_ife.c     | 16 +++++++++++-----
 net/sched/act_ipt.c     | 19 ++++++++++++-------
 net/sched/act_mirred.c  | 22 +++++++++++++++-------
 net/sched/act_simple.c  | 18 ++++++++++++------
 net/sched/act_skbedit.c | 22 +++++++++++++++-------
 net/sched/act_vlan.c    | 22 ++++++++++++++++------
 6 files changed, 81 insertions(+), 38 deletions(-)

-- 
1.9.1
