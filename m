From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: fix crash with vlan and packet size less than
 46
Date: Thu, 13 Sep 2012 17:10:37 -0400 (EDT)
Message-ID: <20120913.171037.995189832370944059.davem@davemloft.net>
References: <1347492769-32409-1-git-send-email-nistrive@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: nistrive@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2IMVKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:10:39 -0400
In-Reply-To: <1347492769-32409-1-git-send-email-nistrive@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nishank Trivedi <nistrive@cisco.com>
Date: Wed, 12 Sep 2012 16:32:49 -0700

> If vlan option is being specified in the pktgen and packet size
> being requested is less than 46 bytes, despite being illogical
> request, pktgen should not crash the kernel.
> 
> BUG: unable to handle kernel paging request at ffff88021fb82000
> Process kpktgend_0 (pid: 1184, threadinfo ffff880215f1a000, task ffff880218544530)
> Call Trace:
> [<ffffffffa0637cd2>] ? pktgen_finalize_skb+0x222/0x300 [pktgen]
> [<ffffffff814f0084>] ? build_skb+0x34/0x1c0
> [<ffffffffa0639b11>] pktgen_thread_worker+0x5d1/0x1790 [pktgen]
> [<ffffffffa03ffb10>] ? igb_xmit_frame_ring+0xa30/0xa30 [igb]
> [<ffffffff8107ba20>] ? wake_up_bit+0x40/0x40
> [<ffffffff8107ba20>] ? wake_up_bit+0x40/0x40
> [<ffffffffa0639540>] ? spin+0x240/0x240 [pktgen]
> [<ffffffff8107b4e3>] kthread+0x93/0xa0
> [<ffffffff81615de4>] kernel_thread_helper+0x4/0x10
> [<ffffffff8107b450>] ? flush_kthread_worker+0x80/0x80
> [<ffffffff81615de0>] ? gs_change+0x13/0x13
> 
> The root cause of why pktgen is not able to handle this case is due
> to comparison of signed (datalen) and unsigned data (sizeof), which
> eventually passes a huge number to skb_put().
> 
> Signed-off-by: Nishank Trivedi <nistrive@cisco.com>

Applied, thanks.
