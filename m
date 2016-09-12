From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/sched: act_tunnel_key: Remove
 rcu_read_lock protection
Date: Mon, 12 Sep 2016 07:17:37 -0700
Message-ID: <1473689857.18970.71.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473682762-8150-1-git-send-email-hadarh@mellanox.com>
         <57D6B710.1080001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34173 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755984AbcILORm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:17:42 -0400
Received: by mail-pa0-f67.google.com with SMTP id ph5so1735772pab.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 07:17:41 -0700 (PDT)
In-Reply-To: <57D6B710.1080001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 07:09 -0700, John Fastabend wrote:
> On 16-09-12 05:19 AM, Hadar Hen Zion wrote:
> > Remove rcu_read_lock protection from tunnel_key_dump and use
> > rtnl_dereference, dump operation is protected by  rtnl lock.
> > 
> > Also, remove rcu_read_lock from tunnel_key_release and use
> > rcu_dereference_protected.
> > 
> > Both operations are running exclusively and a writer couldn't modify
> > t->params while those functions are executed.
> > 
> > Fixes: 54d94fd89d90 ('net/sched: Introduce act_tunnel_key')
> > Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> > ---
> 
> Thanks for cleaning this up.
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Exactly, we now have a nice canonical net/sched/act_... component.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks guys.
