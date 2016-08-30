From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 30 Aug 2016 07:27:18 -0700
Message-ID: <1472567238.14381.297.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
         <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
         <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
         <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
         <20160830110308.GA7141@office.localdomain>
         <bd4cb7ee-1f7e-eefe-760e-0fa53257390e@mojatatu.com>
         <20160830131754.GA11446@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33229 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbcH3O1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 10:27:24 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so1224686pac.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 07:27:23 -0700 (PDT)
In-Reply-To: <20160830131754.GA11446@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 16:17 +0300, Amir Vadai wrote:
> On Tue, Aug 30, 2016 at 08:05:03AM -0400, Jamal Hadi Salim wrote:
> > 
> > old = rtnl_dereference(mykey->p);
> > if (ovr)
> >     spin_lock_bh(&mykey->tcf_lock);
> Thanks for the detailed example :)
> 
> what are we protecting with this spin lock here? isn't concurrent init()
> calls are protected by the rtnl lock?

Right. RTNL should be enough here for the write exclusion.
