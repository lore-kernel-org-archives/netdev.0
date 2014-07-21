From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: avoid generating same handle for u32
 filters
Date: Sun, 20 Jul 2014 20:49:53 -0700 (PDT)
Message-ID: <20140720.204953.867212897376669839.davem@davemloft.net>
References: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbaGUDty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:49:54 -0400
In-Reply-To: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 17 Jul 2014 17:34:53 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> When kernel generates a handle for a u32 filter, it tries to start
> from the max in the bucket. So when we have a filter with the max (fff)
> handle, it will cause kernel always generates the same handle for new
> filters. This can be shown by the following command:
> 
> 	tc qdisc add dev eth0 ingress
> 	tc filter add dev eth0 parent ffff: protocol ip pref 770 handle 800::fff u32 match ip protocol 1 0xff
> 	tc filter add dev eth0 parent ffff: protocol ip pref 770 u32 match ip protocol 1 0xff
> 	...
> 
> we will get some u32 filters with same handle:
> 
>  # tc filter show dev eth0 parent ffff:
> filter protocol ip pref 770 u32 
> filter protocol ip pref 770 u32 fh 800: ht divisor 1 
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
>   match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
>   match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
>   match 00010000/00ff0000 at 8
> filter protocol ip pref 770 u32 fh 800::fff order 4095 key ht 800 bkt 0 
>   match 00010000/00ff0000 at 8
> 
> handles should be unique. This patch fixes it by looking up a bitmap,
> so that can guarantee the handle is as unique as possible. For compatibility,
> we still start from 0x800.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thank you.
