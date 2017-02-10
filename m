From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] l2tp: do not use udp_ioctl()
Date: Fri, 10 Feb 2017 15:58:44 -0500 (EST)
Message-ID: <20170210.155844.1248410088131816631.davem@davemloft.net>
References: <1486654229.7793.100.camel@edumazet-glaptop3.roam.corp.google.com>
        <1486664113.7793.111.camel@edumazet-glaptop3.roam.corp.google.com>
        <1486685752.7793.114.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdBJU6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 15:58:50 -0500
In-Reply-To: <1486685752.7793.114.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Feb 2017 16:15:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> udp_ioctl(), as its name suggests, is used by UDP protocols,
> but is also used by L2TP :(
> 
> L2TP should use its own handler, because it really does not
> look the same.
> 
> SIOCINQ for instance should not assume UDP checksum or headers.
> 
> Thanks to Andrey and syzkaller team for providing the report
> and a nice reproducer.
> 
> While crashes only happen on recent kernels (after commit 
> 7c13f97ffde6 ("udp: do fwd memory scheduling on dequeue")), this
> probably needs to be backported to older kernels.
> 
> Fixes: 7c13f97ffde6 ("udp: do fwd memory scheduling on dequeue")
> Fixes: 85584672012e ("udp: Fix udp_poll() and ioctl()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Acked-by: Paolo Abeni <pabeni@redhat.com>
> ---
> v2: Adding the EXPORT_SYMBOL(l2tp_ioctl) for ipv6, of course...

Applied and queued up for -stable, thanks Eric.
