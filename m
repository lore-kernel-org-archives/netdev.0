From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: avoid NULL deref in inet_ctl_sock_destroy()
Date: Mon, 02 Nov 2015 21:04:01 -0800
Message-ID: <1446527041.23275.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446479407.23275.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151102.224647.1672869809835691426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34608 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbKCFEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 00:04:04 -0500
Received: by padhk6 with SMTP id hk6so1646425pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 21:04:03 -0800 (PST)
In-Reply-To: <20151102.224647.1672869809835691426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 22:46 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 02 Nov 2015 07:50:07 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Under low memory conditions, tcp_sk_init() and icmp_sk_init()
> > can both iterate on all possible cpus and call inet_ctl_sock_destroy(),
> > with eventual NULL pointer.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Dmitry Vyukov <dvyukov@google.com>
> 
> Applied.

Thanks David.

Bug origin was in linux-4.2 :

commit 26abe14379f8e2fa3fd1bcf97c9a7ad9364886fe
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Fri May 8 21:10:31 2015 -0500

    net: Modify sk_alloc to not reference count the netns of kernel sockets.
    
    Now that sk_alloc knows when a kernel socket is being allocated modify
    it to not reference count the network namespace of kernel sockets.
    
    Keep track of if a socket needs reference counting by adding a flag to
    struct sock called sk_net_refcnt.
    
    Update all of the callers of sock_create_kern to stop using
    sk_change_net and sk_release_kernel as those hacks are no longer
    needed, to avoid reference counting a kernel socket.
    
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
