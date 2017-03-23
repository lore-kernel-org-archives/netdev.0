From: David Miller <davem@davemloft.net>
Subject: Re: netlink: NULL timer crash
Date: Thu, 23 Mar 2017 12:00:35 -0700 (PDT)
Message-ID: <20170323.120035.1924712018254677829.davem@davemloft.net>
References: <CACT4Y+Yb9BvzcRT84EriUCqx6hnz_kciYNHjHNX56y1jDb70vw@mail.gmail.com>
        <CANn89i+_+da3PBYjk-KwcUpa6qr0MdqVXOmrsQUM7_VzgBurnA@mail.gmail.com>
        <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, xiyou.wangcong@gmail.com,
        herbert@gondor.apana.org.au, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56332 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932226AbdCWTAm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:00:42 -0400
In-Reply-To: <1490284858.16816.205.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Mar 2017 09:00:58 -0700

> On Thu, 2017-03-23 at 07:53 -0700, Eric Dumazet wrote:
> 
>> Nice !
>> 
>> Looks like neigh->ops->solicit is NULL
> 
> Apparently we allow admins to do really stupid things with neighbours
> on tunnels.
> 
> Following patch should avoid the crash.
> 
> Anyone has better ideas ?

This is probably good enough for now, but you need to also handle
dn_neigh_ops.

Another way to solve this is to add a NULL method check to the
one spot where we invoke this method.  That clearly shows that
the method is optional.
