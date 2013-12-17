From: David Miller <davem@davemloft.net>
Subject: Re: [BUG: 3.13.0-rc4] inconsistent lock state
Date: Tue, 17 Dec 2013 14:24:04 -0500 (EST)
Message-ID: <20131217.142404.421727847441917887.davem@davemloft.net>
References: <52B09446.7060809@t-online.de>
	<CA+55aFyiv7+Ogh=s6VjXChweJHRausBQNJ8LJOv9PvbSZJycVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Knut_Petersen@t-online.de, edumazet@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sbohrer@rgmadvisors.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab3LQTYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:24:07 -0500
In-Reply-To: <CA+55aFyiv7+Ogh=s6VjXChweJHRausBQNJ8LJOv9PvbSZJycVA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 17 Dec 2013 11:06:15 -0800

>  this seems to be due to __udp4_lib_rcv() doing udp_sk_rx_dst_set(),
> which takes the 'sk->sk_dst_lock' spinlock. This all happens in a
> software irq context.

I have a fix for this from Eric that I'll send to you today.
