From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount
 earlier
Date: Thu, 20 Apr 2017 06:28:19 -0400
Message-ID: <f5bb8183-925e-076c-bb64-f1f6be72dee7@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com>
 <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com>
 <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com>
 <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
 <CAM_iQpUPBnWKVHOi2SS6qoeHDPssdj=h03Wg1DLhKk7hbL6_Bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Bumiller <w.bumiller@proxmox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Lucas Bates <lucasb@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34207 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941992AbdDTK2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 06:28:22 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so14770817ioi.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 03:28:21 -0700 (PDT)
In-Reply-To: <CAM_iQpUPBnWKVHOi2SS6qoeHDPssdj=h03Wg1DLhKk7hbL6_Bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-19 01:25 PM, Cong Wang wrote:
> On Wed, Apr 19, 2017 at 4:32 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> This solves one issue, but I am afraid the issue Cong mentioned is a
>> possibility still.
>> Lets say user did a replace and tried to also replace the cookie
>> in that transaction. The init() succeeds but the cookie allocation
>> fails. To be correct we'll have to undo the replace i.e something
>> like uninit() which will restore back the old values.
>> This is very complex and unnecessary.
>
> It is not complex once we move to RCU completely, replacement
> is merely a pointer assignment, rollback is same.
>

Nice to hear.

> It is necessary too according to the rules of RCU, as I said before, the
> current code is broken, we can't modify an existing action with RCU,
> we have to make a copy. I do have plan to make actions truly RCU,
> but I have to redesign the action API's first.

Ok ;->
Lucas: Lets work to get those test suites in.

cheers,
jamal
