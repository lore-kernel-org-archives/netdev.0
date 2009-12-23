From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: min_t/max_t confusion in tcp_select_initial_window()?
Date: Tue, 22 Dec 2009 19:47:47 -0800 (PST)
Message-ID: <20091222.194747.193724694.davem@davemloft.net>
References: <4B3179B8.5000403@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbZLWDrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 22:47:45 -0500
In-Reply-To: <4B3179B8.5000403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 23 Dec 2009 03:00:24 +0100

> I could be confused, but in net/ipv4/tcp_output.c:217:
> 
>                 space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
>                 space = min_t(u32, space, *window_clamp);
> ------------------------^^^^^
> 
> shouldn't the min_t and max_t be exchanged? i.e.
> 
>                 space = min_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
>                 space = max_t(u32, space, *window_clamp);

It looks correct to me.

Globally, the largest window we could ever end up advertising
is the maximum of the sysctl_tcp_rmem[2] threshold and
sysctl_rmem_max.

But for this connection, the window clamp is our upper bound.
