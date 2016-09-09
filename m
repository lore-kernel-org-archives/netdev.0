From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Fri, 9 Sep 2016 08:52:49 -0700
Message-ID: <57D2DAD1.5000306@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com>
 <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D1881B.6090009@gmail.com>
 <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV+ybrM_ebgwX5ZohmKvWZo-8znXkgJv1LhDAC9=3u9Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33804 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIPxB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 11:53:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so4203475pfb.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 08:53:01 -0700 (PDT)
In-Reply-To: <CAM_iQpV+ybrM_ebgwX5ZohmKvWZo-8znXkgJv1LhDAC9=3u9Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-08 10:26 PM, Cong Wang wrote:
> On Thu, Sep 8, 2016 at 8:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2016-09-08 at 08:47 -0700, John Fastabend wrote:
>>
>>> Works for me. FWIW I find this plenty straightforward and don't really
>>> see the need to make the hash table itself rcu friendly.
>>>
>>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>>
>>
>> Yes, it seems this hash table is used in control path, with RTNL held
>> anyway.
> 
> Seriously? You never read hashtable in fast path?? I think you need
> to wake up.
> 

But the actions use refcnt'ing and should never be decremented to zero
as long as they can still be referenced by an active filter. If each
action handles its parameters like mirred/gact then I don't see why its
necessary.

I believe though that the refcnt needs to be fixed a bit though most
likely by making it atomic. I original assumed it was protected by
RTNL lock but because its getting decremented from rcu callback this is
not true.

.John
