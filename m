From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 0/6] net sched: Fix broken late binding of actions
Date: Tue, 10 May 2016 16:49:25 -0400
Message-ID: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
	alexander.duyck@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32977 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbcEJUtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:49:40 -0400
Received: by mail-io0-f194.google.com with SMTP id x35so3143066ioi.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 13:49:40 -0700 (PDT)
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
  net sched: vlan action fix late binding
  net sched: ipt action fix late binding
  net sched: mirred action fix late binding
  net sched: simple action fix late binding
  net sched: skbedit action fix late binding
  net sched: ife action fix late binding

 net/sched/act_ife.c     | 14 ++++++++++----
 net/sched/act_ipt.c     | 19 ++++++++++++-------
 net/sched/act_mirred.c  | 19 +++++++++++++------
 net/sched/act_simple.c  | 18 ++++++++++++------
 net/sched/act_skbedit.c | 18 +++++++++++-------
 net/sched/act_vlan.c    | 22 ++++++++++++++++------
 6 files changed, 74 insertions(+), 36 deletions(-)

-- 
1.9.1
