From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: dst_entry leak in ip_append_data()
Date: Tue, 14 Oct 2014 16:12:25 -0400 (EDT)
Message-ID: <20141014.161225.1399177558139744041.davem@davemloft.net>
References: <543CAD2A.3070701@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com
To: vvs@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbaJNUM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:12:29 -0400
In-Reply-To: <543CAD2A.3070701@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>
Date: Tue, 14 Oct 2014 08:57:14 +0400

> v2: adjust the indentation of the arguments __ip_append_data() call
> 
> Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")
> 
> If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
> that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
> that creates skb and adds it to sk_write_queue.
> 
> If skb was added successfully following ip_push_pending_frames() call
> reassign dst entries from cork to skb, and kfree_skb frees dst_entry.
> 
> However nobody frees stolen dst_entry if skb was not added into sk_write_queue.
> 
> Signed-off-by: Vasily Averin <vvs@parallels.com>

Why doesn't ip_make_skb() need the same fix?  It seems to do the same
thing.
