From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 01/16] net_sched: introduce a workqueue for RCU
 callbacks of tc filter
Date: Fri, 27 Oct 2017 08:37:10 -0700
Message-ID: <CAM_iQpXFw8NcVLLgErTNP8yCeZY+wv5zXDfveCcb6cHN0u5NyQ@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <20171027012443.3306-2-xiyou.wangcong@gmail.com> <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUB_y5=Pa9z5Vq+Ves9GhT5COXvRbDtRZo2xqxjo__vmw@mail.gmail.com> <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:46198 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdJ0Phb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:37:31 -0400
Received: by mail-pg0-f66.google.com with SMTP id k7so5569415pga.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 08:37:31 -0700 (PDT)
In-Reply-To: <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 9:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-10-26 at 21:28 -0700, Cong Wang wrote:
>> On Thu, Oct 26, 2017 at 9:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Paul pointed out the same.
>>
>> As I replied, this rcu_barrier() is NOT added by this patchset, it is already
>> there in current master branch.
>
> You added the rtnl_lock()  rtnl_unlock()...


Unfortunately you are wrong again, tcf_block_put() holds RTNL
in current code as well...


>
> I really do not care if hundreds of tasks (not owning rtnl) call
> rcu_barrier()...
>

You are so welcome to improve current code base, but why keep
blaming my patchset which neither introduces any rcu_barrier()
nor any RTNL? Did you even take a look at current master branch?


> Also we are still using a 4.3 based kernel, and no rcu_barrier() is used
> in filters dismantle ( unregister_tcf_proto_ops() is not used in our
> workloads )


My patchset is unfortunately not based on 4.3, this argument is totally
nonsense.

Also, filter block was introduced during v4.13.


>
> Somehow something went very wrong in net/sched in recent kernels.
>

What stops you to optimize current code?
