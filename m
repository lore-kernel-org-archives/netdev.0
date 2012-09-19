From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: flush DMA queue before sk_wait_data if
 rcv_wnd is zero
Date: Wed, 19 Sep 2012 16:10:20 -0400 (EDT)
Message-ID: <20120919.161020.2081071541564248020.davem@davemloft.net>
References: <20120914170432.C8B8DC6405@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482Ab2ISUKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:10:22 -0400
In-Reply-To: <20120914170432.C8B8DC6405@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 14 Sep 2012 16:59:52 +0200

> If recv() syscall is called for a TCP socket so that
>   - IOAT DMA is used
>   - MSG_WAITALL flag is used
>   - requested length is bigger than sk_rcvbuf
>   - enough data has already arrived to bring rcv_wnd to zero
> then when tcp_recvmsg() gets to calling sk_wait_data(), receive
> window can be still zero while sk_async_wait_queue exhausts
> enough space to keep it zero. As this queue isn't cleaned until
> the tcp_service_net_dma() call, sk_wait_data() cannot receive
> any data and blocks forever.
> 
> If zero receive window and non-empty sk_async_wait_queue is
> detected before calling sk_wait_data(), process the queue first.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable, thanks.

> Cc: <stable@vger.kernel.org>

Please do not CC: stable on networking bug fixes like this.

Simply ask me to add it to the networking -stable queue instead.

I do not want fixes to propagate immedately to -stable right when they
hit Linus's tree.  Rather, I want them to soak upstream for a while
before they get submitted to -stable.

And that's why I maintain a special queue for networking fixes
which should be submitted to -stable at some point in the future
at:

	http://patchwork.ozlabs.org/user/bundle/2566/?state=*

Thanks.
