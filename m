From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Check frag_lists first to prevent data
 out of order
Date: Thu, 27 Aug 2015 21:26:39 -0700 (PDT)
Message-ID: <20150827.212639.868701692675372953.davem@davemloft.net>
References: <1440641561.8932.36.camel@edumazet-glaptop2.roam.corp.google.com>
	<1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<55DFD70C.2030001@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
	alexander.h.duyck@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbH1E0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 00:26:41 -0400
In-Reply-To: <55DFD70C.2030001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>
Date: Fri, 28 Aug 2015 11:35:40 +0800

> In my test, @to has a fraglist, but skb_tailroom(to) is not 0!
> The test is about tipc, the function tipc_buf_append will merge 3 skbs
> to one:
> packet 1: len = 1420 skb_tailroom = 190
> packet 2: len = 1420
> 	packet 2 will be add to 1' fraglist, but not update skb_tailroom

This operation is illegal.

Once there are frags, tailroom is not permitted.
