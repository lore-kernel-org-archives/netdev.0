From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: open sockets preventing unregister_netdevice from completing
 in linux-next (next-20120724)
Date: Thu, 26 Jul 2012 19:15:28 +0200
Message-ID: <1343322928.2626.11764.camel@edumazet-glaptop>
References: <87boj4hs3k.fsf@nemi.mork.no>
	 <1343227128.2626.11157.camel@edumazet-glaptop>
	 <20120725.151737.1807149851147342859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47820 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab2GZRPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 13:15:33 -0400
Received: by bkwj10 with SMTP id j10so1416287bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 10:15:32 -0700 (PDT)
In-Reply-To: <20120725.151737.1807149851147342859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 15:17 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 25 Jul 2012 16:38:48 +0200
> 
> > Yes, we miss what was done with rt_cache_flush() : find all cached
> > routes and release all dev references...
> 
> We can fix this with a two-pronged approach:
> 
> 1) Walk the FIB info nexthops and invalidate.
> 
> 2) Entries not cached in the FIB info nexthops go into a
>    per-netns list which is scanned as well.
> 
> I'll try to work on this if nobody beats me to it.

With your latest patch, I can "rmmod tg3" while sockets are active.

Not sure we need all this now ?

(the trick is probably in fib_semantics.c, when you changed
dst_release() to dst_free())
