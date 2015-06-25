From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] enic: use atomic_t instead of spin_lock in
 busy poll
Date: Thu, 25 Jun 2015 05:23:27 -0700 (PDT)
Message-ID: <20150625.052327.1461706804571236235.davem@davemloft.net>
References: <1435228324-11560-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbFYMLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:11:33 -0400
In-Reply-To: <1435228324-11560-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu, 25 Jun 2015 16:02:04 +0530

> We use spinlock to access a single flag. We can avoid spin_locks by using
> atomic variable and atomic_cmpxchg(). Use atomic_cmpxchg to set the flag
> for idle to poll. And a simple atomic_set to unlock (set idle from poll).
> 
> In napi poll, if gro is enabled, we call napi_gro_receive() to deliver the
> packets. Before we call napi_complete(), i.e while re-polling, if low
> latency busy poll is called, we use netif_receive_skb() to deliver the packets.
> At this point if there are some skb's held in GRO, busy poll could deliver the
> packets out of order. So we call napi_gro_flush() to flush skbs before we
> move the napi poll to idle.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thanks.
