From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] tcp: syncookies: extend validity range
Date: Thu, 14 May 2015 23:45:44 +0200
Message-ID: <20150514214544.GF6179@breakpoint.cc>
References: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47264 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161024AbbENVpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 17:45:47 -0400
Content-Disposition: inline
In-Reply-To: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Now we allow storing more request socks per listener, we might
> hit syncookie mode less often and hit following bug in our stack :
> 
> When we send a burst of syncookies, then exit this mode,
> tcp_synq_no_recent_overflow() can return false if the ACK packets coming
> from clients are coming three seconds after the end of syncookie
> episode.

Heh.  Indeed.  This dates back to original from 1997...

> This is a way too strong requirement and conflicts with rest of
> syncookie code which allows ACK to be aged up to 2 minutes.
> 
> Perfectly valid ACK packets are dropped just because clients might be
> in a crowded wifi environment or on another planet.
> 
> So let's fix this, and also change tcp_synq_overflow() to not
> dirty a cache line for every syncookie we send, as we are under attack.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> As this is an old bug, I chose net-next tree.

Looks great, thanks Eric!

Acked-by: Florian Westphal <fw@strlen.de>
