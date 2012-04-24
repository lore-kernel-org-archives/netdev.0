From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] set fake_rtable's dst to NULL to avoid kernel Oops
Date: Tue, 24 Apr 2012 00:17:35 -0400 (EDT)
Message-ID: <20120424.001735.1975136616657606100.davem@davemloft.net>
References: <4F90FE63.9060800@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, peter.huangpeng@gmail.com,
	linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	ctrix+debianbugs@navynet.it
To: peter.huangpeng@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab2DXESu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:18:50 -0400
In-Reply-To: <4F90FE63.9060800@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Date: Fri, 20 Apr 2012 14:12:51 +0800

> bridge: set fake_rtable's dst to NULL to avoid kernel Oops
> 
> when bridge is deleted before tap/vif device's delete, kernel may
> encounter an oops because of NULL reference to fake_rtable's dst.
> Set fake_rtable's dst to NULL before sending packets out can solve
> this problem.
> 
> v4 reformat, change br_drop_fake_rtable(skb) to {}
> 
> v3 enrich commit header
> 
> v2 introducing new flag DST_FAKE_RTABLE to dst_entry struct.
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>

Applied, although I changed to nop br_drop_fake_rtable() implementation
to use "do { } while (0)" instead of just plain "{ }".
