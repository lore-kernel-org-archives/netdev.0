From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 19:46:50 +0200
Message-ID: <1337795210.3361.3118.camel@edumazet-glaptop>
References: <1337705135.3361.226.camel@edumazet-glaptop>
	 <1337720076.3361.667.camel@edumazet-glaptop>
	 <1337766246.3361.2447.camel@edumazet-glaptop>
	 <20120523.133401.915684077769386834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kmansley@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54106 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760641Ab2EWRqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 13:46:55 -0400
Received: by eaak11 with SMTP id k11so2161352eaa.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 10:46:54 -0700 (PDT)
In-Reply-To: <20120523.133401.915684077769386834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 13:34 -0400, David Miller wrote:

> But it is the only way we can have TCP processing scheduled and
> accounted to user processes.  That does have value when you have lots
> of flows active.
> 
> The scheduler's ability to give the process cpu time influences
> TCP's behavier, and under load if the process can't get enough
> cpu time then TCP will back off.  We want that.

But TCP already backs off if user process is not blocked on socket
input.

Modern applications uses select()/poll()/epoll() on many sockets in //.

Only old ones stil block on recv().
