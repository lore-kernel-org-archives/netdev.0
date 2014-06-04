From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] rtnetlink: fix a memory leak when ->newlink fails
Date: Tue, 03 Jun 2014 19:17:06 -0700 (PDT)
Message-ID: <20140603.191706.1773783531239967313.davem@davemloft.net>
References: <1401838847-5982-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaFDCRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:17:07 -0400
In-Reply-To: <1401838847-5982-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  3 Jun 2014 16:40:47 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> It is possible that ->newlink() fails before registering
> the device, in this case we should just free it, it's
> safe to call free_netdev().
> 
> Fixes: commit 0e0eee2465df77bcec2 (net: correct error path in rtnl_newlink())
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

It's a bit ugly, but I can't come up with a better fix, so applied.

This is difficult because it is the one set of code paths where the
netdev allocator and the register are decoupled.
