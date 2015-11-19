From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix potential huge kmalloc() calls in
 TCP_REPAIR
Date: Thu, 19 Nov 2015 04:25:55 -0800
Message-ID: <1447935955.22599.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447909413.22599.191.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564DA9AD.80400@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34972 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbKSMZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 07:25:57 -0500
Received: by pacej9 with SMTP id ej9so79981730pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 04:25:56 -0800 (PST)
In-Reply-To: <564DA9AD.80400@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 13:51 +0300, Pavel Emelyanov wrote:
> On 11/19/2015 08:03 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > tcp_send_rcvq() is used for re-injecting data into tcp receive queue.
> > 
> > Problems :
> > 
> > - No check against size is performed, allowed user to fool kernel in
> >   attempting very large memory allocations, eventually triggering
> >   OOM when memory is fragmented.
> 
> Doesn't the tcp_try_rmem_schedule() protect us from doing this "eventually"?
> I mean first we would be allowed to do it, but then the sock will be charged
> with the previous allocations and will not add more memory to socket.

But this tcp_try_rmem_schedule() is done _after_ allocation was
attempted. This is too late :(
