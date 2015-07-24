From: subashab@codeaurora.org
Subject: Re: [PATCH net-next] inet: Always increment refcount in
 inet_twsk_schedule
Date: Fri, 24 Jul 2015 01:49:27 -0000
Message-ID: <b4cafdee6aa80ecc2e36f1499c4145b9.squirrel@www.codeaurora.org>
References: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
    <1437295872.1026.37.camel@edumazet-glaptop2.roam.corp.google.com>
    <99d6ce13c5da5ea403b3df747d770d54.squirrel@www.codeaurora.org>
    <1437462610.1026.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36906 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbbGXBt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 21:49:28 -0400
In-Reply-To: <1437462610.1026.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually we do increment refcnt, for every socket found in ehash.
>
> Carefully read again __inet_lookup_established()
>
> This code is generic for ESTABLISH and TIME-WAIT sockets
>
> If you found a code that performed the lookup without taking the refcnt,
> please point me at it, this would be a serious bug.

>From my previous observations, it appears as if
1. this check is bypassed
2. the refcount is incremented here but is decremented before it reaches
the packet processing in tcp_timewait_state_process()

I will try to debug this and update.

> Is it some Android kernel ?
>
> Android had private modules that needed an update in 3.18

Yes, the kernel is based on Android 3.18.
