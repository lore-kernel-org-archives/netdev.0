From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount earlier
Date: Wed, 19 Apr 2017 14:32:27 -0700
Message-ID: <CAM_iQpWxZj8JPOfrQQzhhe=T+Z8-DHk5w+6ccUhTvYAv9Wz8kA@mail.gmail.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com> <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com> <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com> <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
 <1244443915.139.1492614192777@webmail.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34036 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939800AbdDSVct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:32:49 -0400
Received: by mail-wm0-f49.google.com with SMTP id r190so16905625wme.1
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 14:32:48 -0700 (PDT)
In-Reply-To: <1244443915.139.1492614192777@webmail.proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 8:03 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
>> On April 19, 2017 at 1:32 PM Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> My suggestion:
>> If we move the cookie allocation before init we can save it and
>> only when init succeeds do we attach it to the action, otherwise
>> we free it on error path.
>
> Shouldn't the old code have freed an old a->act_cookie as well before
> replacing it then? nla_memdup_cookie() starts off by assigning a->act_cookie.
>

Yeah. Looks even better, we can totally avoid rollback the action modification
rollback on failure.
