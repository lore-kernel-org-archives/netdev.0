From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: syncookies: extend validity range
Date: Thu, 14 May 2015 22:33:21 -0400 (EDT)
Message-ID: <20150514.223321.1648157993009055494.davem@davemloft.net>
References: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, ncardwell@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423545AbbEOCdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:33:22 -0400
In-Reply-To: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 May 2015 14:26:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Now we allow storing more request socks per listener, we might
> hit syncookie mode less often and hit following bug in our stack :
> 
> When we send a burst of syncookies, then exit this mode,
> tcp_synq_no_recent_overflow() can return false if the ACK packets coming
> from clients are coming three seconds after the end of syncookie
> episode.
> 
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

Applied, thanks.
