From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 2/2] net sched actions: decrement module refcount earlier
Date: Wed, 19 Apr 2017 10:25:18 -0700
Message-ID: <CAM_iQpUPBnWKVHOi2SS6qoeHDPssdj=h03Wg1DLhKk7hbL6_Bg@mail.gmail.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
 <20170418101322.27666-2-w.bumiller@proxmox.com> <CAM_iQpWQYsqGD3TZp=iXyK0auprgo5uUbRZRvtpnFjQWwCj5Gw@mail.gmail.com>
 <b34fa5f5-5368-672a-be06-4c9801b8114e@mojatatu.com> <CAM_iQpVucDgy-=ToNrH1a9h1h7goK33hfY_o30e5Rz1Pqwj4_A@mail.gmail.com>
 <462700507.23.1492589388406@webmail.proxmox.com> <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Bumiller <w.bumiller@proxmox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35711 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968253AbdDSRZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 13:25:40 -0400
Received: by mail-wm0-f49.google.com with SMTP id w64so85893136wma.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 10:25:39 -0700 (PDT)
In-Reply-To: <861dba23-1244-ee57-a980-a6dceffa2793@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 4:32 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> This solves one issue, but I am afraid the issue Cong mentioned is a
> possibility still.
> Lets say user did a replace and tried to also replace the cookie
> in that transaction. The init() succeeds but the cookie allocation
> fails. To be correct we'll have to undo the replace i.e something
> like uninit() which will restore back the old values.
> This is very complex and unnecessary.

It is not complex once we move to RCU completely, replacement
is merely a pointer assignment, rollback is same.

It is necessary too according to the rules of RCU, as I said before, the
current code is broken, we can't modify an existing action with RCU,
we have to make a copy. I do have plan to make actions truly RCU,
but I have to redesign the action API's first.
