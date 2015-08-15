From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] ipv4: fix refcount leak in fib_check_nh()
Date: Sat, 15 Aug 2015 14:36:09 -0600
Message-ID: <55CFA2B9.50207@cumulusnetworks.com>
References: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com>	 <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>	 <55CE7776.5000706@cumulusnetworks.com>	 <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com> <1439661247.7258.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33561 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753876AbbHOUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 16:36:12 -0400
Received: by pabyb7 with SMTP id yb7so80603042pab.0
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 13:36:12 -0700 (PDT)
In-Reply-To: <1439661247.7258.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/15 11:54 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> fib_lookup() forces FIB_LOOKUP_NOREF flag, while fib_table_lookup()
> does not.
>
> This patch solves the typical message at reboot time or device
> dismantle :
>
> unregister_netdevice: waiting for eth0 to become free. Usage count = 4
>
> Fixes: 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>

Still puzzled why I was not seeing the refcnt problem at reboot though I 
did see the extra dev_hold when I instrumented the hold and put. 
Anyways, thanks for resolving, Eric.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
