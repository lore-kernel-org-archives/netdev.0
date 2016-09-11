From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix GETing actions
Date: Sun, 11 Sep 2016 12:30:00 -0400
Message-ID: <0b66983d-c316-9084-0f2c-6993cbf1f56d@mojatatu.com>
References: <1473336754-24930-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpUrbikYYfttzEn8AihpSmXtwrdnV-949BzVH_0DdwW37g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35486 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751044AbcIKQaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 12:30:03 -0400
Received: by mail-oi0-f51.google.com with SMTP id d191so42462391oih.2
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 09:30:02 -0700 (PDT)
In-Reply-To: <CAM_iQpUrbikYYfttzEn8AihpSmXtwrdnV-949BzVH_0DdwW37g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-08 01:12 PM, Cong Wang wrote:

>> +}
>> +
>>  static int
>>  tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>>               u32 portid, int event)
>> @@ -883,6 +894,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>>                         goto err;
>>                 }
>>                 act->order = i;
>> +               act->tcfa_refcnt+=1;
>
>
> Maybe we only need to fixup the refcnt without touching list,
> from my quick observation to your bug report (again, you didn't explain).
>

Yes, you are correct. clearing the list is unnecessary since it is
temporary. When i get the chance i will fix it up, test and resubmit.

What do you want the commit message to say? It shows an example because
the functionality broke.

cheers,
jamal
