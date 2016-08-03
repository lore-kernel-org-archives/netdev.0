From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: remove the leftover cleanup_a()
Date: Wed, 3 Aug 2016 07:36:29 -0400
Message-ID: <d82351ba-cd1e-d5e1-0faa-94c2bcaf720a@mojatatu.com>
References: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35833 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbcHCMkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 08:40:10 -0400
Received: by mail-io0-f176.google.com with SMTP id m101so241382850ioi.2
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 05:40:09 -0700 (PDT)
In-Reply-To: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong,

Improvement on the basic test as it no longer oopses, but:
here's a test that will oops:
-----------------------------
# add action that will be shared for multi-flows
sudo tc actions add action drop index 10
#add an action noone uses
sudo tc actions add action ok index 12
#
sudo tc actions ls action gact
# see both dumped... (good)
#Lets bind the shared action twice
#
sudo tc qdisc del dev lo parent ffff:
sudo tc qdisc add dev lo ingress
#
#use existing action index 10
sudo tc filter add dev lo parent ffff: protocol ip prio 8 \
u32 match ip dst 127.0.0.8/32 flowid 1:10 action gact index 10
#use existing action index 10
sudo tc filter add dev lo parent ffff: protocol ip prio 7 \
u32 match ip src 127.0.0.10/32 flowid 1:11 action gact index 10
# and now dump and see an oops
sudo tc filter ls dev lo parent ffff: protocol ip
-------------------

And btw, this should be submitted to -net not -net-next and should
specify something along the lines of "broken-by .."

cheers,
jamal
