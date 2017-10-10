From: Alexander Aring <aring@mojatatu.com>
Subject: [RFC net 0/1] net: sched: act: fix rcu race
Date: Tue, 10 Oct 2017 08:32:17 -0400
Message-ID: <20171010123218.5251-1-aring@mojatatu.com>
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        kurup.manish@gmail.com, bjb@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50430 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbdJJMch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 08:32:37 -0400
Received: by mail-it0-f65.google.com with SMTP id 72so2244725itl.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 05:32:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while I reading tc action code to debug a "it does not work" statement I
suppose I detected issues with the current rcu handling of tc actions.

There are more than just skbmod which do it wrong. Anyway if somebody agree
with me here I will send more patches which fix this behaviour in other tc
actions where code was just copy&pasted.

The problem because nobody hits this issue is, I think that dump will do alot
of previous stuff which took more time than a rcu_synchronize. Anyway, this
change should avoid any use after free issues etc.

- Alex

Alexander Aring (1):
  net: sched: act: fix rcu race in dump

 net/sched/act_skbmod.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

-- 
2.11.0
