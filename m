From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Thu, 20 Apr 2017 06:24:54 -0400
Message-ID: <f0b2afb3-dfaf-3bff-4d60-e7ed8fecbbb6@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
 <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com>
 <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
 <1244443915.139.1492614192777@webmail.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33253 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941064AbdDTKZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 06:25:01 -0400
Received: by mail-io0-f176.google.com with SMTP id k87so64361624ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 03:25:01 -0700 (PDT)
In-Reply-To: <1244443915.139.1492614192777@webmail.proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 11:03 AM, Wolfgang Bumiller wrote:
>> On April 19, 2017 at 1:32 PM Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>
>>
>> On 17-04-19 04:09 AM, Wolfgang Bumiller wrote:
>>
>> This solves one issue, but I am afraid the issue Cong mentioned is a
>> possibility still.
>> Lets say user did a replace and tried to also replace the cookie
>> in that transaction. The init() succeeds but the cookie allocation
>> fails. To be correct we'll have to undo the replace i.e something
>> like uninit() which will restore back the old values.
>> This is very complex and unnecessary.
>>
>> My suggestion:
>> If we move the cookie allocation before init we can save it and
>> only when init succeeds do we attach it to the action, otherwise
>> we free it on error path.
>
> Shouldn't the old code have freed an old a->act_cookie as well before
> replacing it then? nla_memdup_cookie() starts off by assigning a->act_cookie.
>
> (I've been running this loop for a while now:
> # while : ; do tc actions change action ok index 500 cookie $i; let i++; done
> and memory usage *seems* to be growing faster with the loop running - still
> slow, but visible. (I stopped most but not all background processes in this
> VM))
>
> I don't see the growth with the change below (replacing both patches).
> (although given the freeing of the old act_cookie pointer I wonder if
> this needs additional locking?)
>

I think we are safe. The cookie should not be touched by any datapath
code.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
