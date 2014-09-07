From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Sun, 07 Sep 2014 16:17:20 -0700 (PDT)
Message-ID: <20140907.161720.168413856991894569.davem@davemloft.net>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
	<CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbaIGXRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:17:20 -0400
In-Reply-To: <CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>
Date: Sun, 7 Sep 2014 17:24:11 +0800

> 2.  I did not find that tx_dropped/tx_error/.. is protected by spin
> lock under net dir,
> sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
> sometime it is
> u64,but does not need to protect.

If it is only modified in ->ndo_start_xmit() then it is protected by
the per-queue TX lock, as ->ndo_start_xmit() is always invoked with
it held (except in LLTX drivers of course).
