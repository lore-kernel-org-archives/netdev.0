From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/5] net: fix races accessing page->_count
Date: Fri, 10 Oct 2014 15:37:59 -0400 (EDT)
Message-ID: <20141010.153759.1185343188717400584.davem@davemloft.net>
References: <1412941698-17502-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@redhat.com,
	jeffrey.t.kirsher@intel.com, andreslc@google.com,
	gthelen@google.com, hughd@google.com, rientjes@google.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbaJJTiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:38:02 -0400
In-Reply-To: <1412941698-17502-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 10 Oct 2014 04:48:13 -0700

> This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
> the page. Other entities in the kernel need to use get_page_unless_zero()
> to get a reference to the page before testing page properties, so we could
> loose a refcount increment.
> 
> The only case it is valid is when page->_count is 0, we can use this in
> __netdev_alloc_frag()
> 
> Note that I never seen crashes caused by these races, the issue was reported
> by Andres Lagar-Cavilla and Hugh Dickins.

Series applied, thanks Eric.
