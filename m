From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v5 0/2] net sched actions: improve action dump performance
Date: Thu, 20 Apr 2017 09:06:20 -0400
Message-ID: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
Cc: jiri@resnulli.us, xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33908 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942993AbdDTNIS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:08:18 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so16273198ioi.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 06:08:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes since v4:

1) Eric D.

pointed out that when all skb space is used up by the dump
there will be no space to insert the TCAA_ACT_COUNT attribute.

2) Jiri:

i) Change:

enum {
        TCAA_UNSPEC,
        TCAA_ACT_TAB,
        TCAA_ACT_FLAGS,
        TCAA_ACT_COUNT,
        TCAA_ACT_TIME_FILTER,
        __TCAA_MAX
};

#define TCAA_MAX (__TCAA_MAX - 1)
#define ACT_LARGE_DUMP_ON               (1 << 0)

to:
enum {
       TCAA_UNSPEC,
       TCAA_ACT_TAB,
#define TCA_ACT_TAB TCAA_ACT_TAB
       TCAA_ACT_FLAGS,
       TCAA_ACT_COUNT,
       __TCAA_MAX,
#define        TCAA_MAX (__TCAA_MAX - 1)
};

#define ACT_LARGE_DUMP_ON              BIT(0)

Jiri plans to followup with the rest of the code to make the
style consistent.

ii) Rename attribute TCAA_ACT_TIME_FILTER --> TCAA_ACT_TIME_DELTA

iii) Rename variable jiffy_filter --> jiffy_since
iv) Rename msecs_filter --> msecs_since
v) get rid of unused cb->args[0] and rename cb->args[4] to cb->args[0]

Jamal Hadi Salim (2):
  net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
  net sched actions: add time filter for action dumping

 include/uapi/linux/rtnetlink.h | 22 ++++++++++++--
 net/sched/act_api.c            | 66 +++++++++++++++++++++++++++++++++++-------
 2 files changed, 75 insertions(+), 13 deletions(-)

-- 
1.9.1
