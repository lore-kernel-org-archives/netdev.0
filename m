From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: correct error path in rtnl_newlink()
Date: Thu, 13 Feb 2014 17:13:28 -0500 (EST)
Message-ID: <20140213.171328.358063722549274810.davem@davemloft.net>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<1392162690-6647-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbaBMWNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:13:31 -0500
In-Reply-To: <1392162690-6647-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Feb 2014 15:51:30 -0800

> From: Cong Wang <cwang@twopensource.com>
> 
> I saw the following BUG when ->newlink() fails in rtnl_newlink():
> 
> [   40.240058] kernel BUG at net/core/dev.c:6438!
> 
> this is due to free_netdev() is not supposed to be called before
> netdev is completely unregistered, therefore it is not correct
> to call free_netdev() here, at least for ops->newlink!=NULL case,
> many drivers call it in ->destructor so that rtnl_unlock() will
> take care of it, we probably don't need to do anything here.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.
