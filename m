From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] cls_u32: complete the check for non-forced case in
 u32_destroy()
Date: Tue, 25 Aug 2015 17:03:20 -0700 (PDT)
Message-ID: <20150825.170320.1396879313030005663.davem@davemloft.net>
References: <1440545892-20587-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akshat.1984@gmail.com, jhs@mojatatu.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319AbbHZADV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:03:21 -0400
In-Reply-To: <1440545892-20587-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 25 Aug 2015 16:38:12 -0700

> In commit 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> I added a check in u32_destroy() to see if all real filters are gone
> for each tp, however, that is only done for root_ht, same is needed
> for others.
> 
> This can be reproduced by the following tc commands:
> 
> tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
> ht 15:2: match ip src 10.0.0.2 flowid 1:10
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
> ht 15:2: match ip src 10.0.0.3 flowid 1:10
> 
> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> Reported-by: Akshat Kakkar <akshat.1984@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied and queued up for -stable, thanks.
