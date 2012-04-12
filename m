From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC udp: improve __udp4_lib_lookup performance
Date: Thu, 12 Apr 2012 16:00:15 +0200
Message-ID: <1334239215.5300.6475.camel@edumazet-glaptop>
References: <CAHG7+CAt_YjxUp6+u9J47Ti1HA6hh_UkRMWQsXw4AsbEkvCu7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:32832 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809Ab2DLOAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 10:00:22 -0400
Received: by bkcik5 with SMTP id ik5so1538803bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 07:00:20 -0700 (PDT)
In-Reply-To: <CAHG7+CAt_YjxUp6+u9J47Ti1HA6hh_UkRMWQsXw4AsbEkvCu7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 16:35 +0300, Alexandru Copot wrote:
> UDP uses 2 hashtables for fast socket lookup. First hash uses port as
> a lookup key and the second one uses (port, addr).
> 
> When an UDP packet is received, the destination socket must be found to
> deliver it. If there are many UDP sockets bound to INADDR_ANY, 2 hash
> searches are made in the second hash: first one looks for the pair
> (dest address, dest port) but doesn't find the socket; the second search
> finds the socket by hashing (INADDR_ANY, dest port).
> 
> Those 2 searches can be avoided and a lot of time saved if instead we
> searched directly in the first hash.
> 
> We could count the number of INADDR_ANY bound UDP sockets and
> make only one search when that value is above a certain threshold. However,
> if there are also sockets bound on a specific address, the second hash
> won't be used and that might hurt performance for this case.
> 
> What is your opinion on this ? Would the performance gained by
> counting INADDR_ANY bound sockets outweigh the loss in performance
> for the case of mixed INADDR_ANY/specific address bound sockets ?

I have no idea of your workload, but existing code is already very
optimized.

udp4_lib_lookup2() variants are only called when (hslot->count > 10)

If your workload have one 60000 UDP sockets bound on INADDR_ANY, I
suggest you check udp hash size and eventually increase it to the max ?

dmesg | grep "UDP hash"

Boot command : uhash_entries=65536
