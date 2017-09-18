From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: cls_matchall: fix crash when used with
 classful qdisc
Date: Mon, 18 Sep 2017 16:38:07 -0700 (PDT)
Message-ID: <20170918.163807.719055481647996620.davem@davemloft.net>
References: <b930159de5531a4d216a1cd2c2ef03aa41f421f9.1505562794.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, jhs@mojatatu.com, jbenc@redhat.com,
        netdev@vger.kernel.org
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdIRXiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:38:08 -0400
In-Reply-To: <b930159de5531a4d216a1cd2c2ef03aa41f421f9.1505562794.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Sat, 16 Sep 2017 14:02:21 +0200

> this script, edited from Linux Advanced Routing and Traffic Control guide
> 
> tc q a dev en0 root handle 1: htb default a
> tc c a dev en0 parent 1:  classid 1:1 htb rate 6mbit burst 15k
> tc c a dev en0 parent 1:1 classid 1:a htb rate 5mbit ceil 6mbit burst 15k
> tc c a dev en0 parent 1:1 classid 1:b htb rate 1mbit ceil 6mbit burst 15k
> tc f a dev en0 parent 1:0 prio 1 $clsname $clsargs classid 1:b
> ping $address -c1
> tc -s c s dev en0
> 
> classifies traffic to 1:b or 1:a, depending on whether the packet matches
> or not the pattern $clsargs of filter $clsname. However, when $clsname is
> 'matchall', a systematic crash can be observed in htb_classify(). HTB and
> classful qdiscs don't assign initial value to struct tcf_result, but then
> they expect it to contain valid values after filters have been run. Thus,
> current 'matchall' ignores the TCA_MATCHALL_CLASSID attribute, configured
> by user, and makes HTB (and classful qdiscs) dereference random pointers.
> 
> By assigning head->res to *res in mall_classify(), before the actions are
> invoked, we fix this crash and enable TCA_MATCHALL_CLASSID functionality,
> that had no effect on 'matchall' classifier since its first introduction.
> 
> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1460213
> Reported-by: Jiri Benc <jbenc@redhat.com>
> Fixes: b87f7936a932 ("net/sched: introduce Match-all classifier")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied and queued up for -stable, thanks.
