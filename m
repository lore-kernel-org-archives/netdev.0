From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: rx mmap: fix POLLIN condition
Date: Sun, 30 Aug 2015 21:56:03 -0700 (PDT)
Message-ID: <20150830.215603.1010137816632495971.davem@davemloft.net>
References: <20150825.201712.2151042716686513603.davem@davemloft.net>
	<20150828070058.GA32596@gmail.com>
	<20150830225449.GA9533@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbHaE4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 00:56:04 -0400
In-Reply-To: <20150830225449.GA9533@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Mon, 31 Aug 2015 07:54:49 +0900

> Poll() returns immediately after setting the kernel current frame
> (ring->head) to SKIP from user space even though there is no new
> frame. And in a case of all frames is VALID, user space program
> unintensionally sets (only) kernel current frame to UNUSED, then
> calls poll(), it will not return immediately even though there are
> VALID frames.
> 
> To avoid situations like above, I think we need to scan all frames
> to find VALID frames at poll() like netlink_alloc_skb(),
> netlink_forward_ring() finding an UNUSED frame at skb allocation.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

Applied, thanks.
