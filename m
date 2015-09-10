From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink, mmap: don't walk rx ring on poll if
 receive queue non-empty
Date: Wed, 09 Sep 2015 21:43:42 -0700 (PDT)
Message-ID: <20150909.214342.191904339315763716.davem@davemloft.net>
References: <5e369c9aa5889383aece50a6b5c22256b19ab334.1441839128.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbIJEnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 00:43:43 -0400
In-Reply-To: <5e369c9aa5889383aece50a6b5c22256b19ab334.1441839128.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 10 Sep 2015 01:20:46 +0200

> In case of netlink mmap, there can be situations where received frames
> have to be placed into the normal receive queue. The ring buffer indicates
> this through NL_MMAP_STATUS_COPY, so the user is asked to pick them up
> via recvmsg(2) syscall, and to put the slot back to NL_MMAP_STATUS_UNUSED.
> 
> Commit 0ef707700f1c ("netlink: rx mmap: fix POLLIN condition") changed
> polling, so that we walk in the worst case the whole ring through the
> new netlink_has_valid_frame(), for example, when the ring would have no
> NL_MMAP_STATUS_VALID, but at least one NL_MMAP_STATUS_COPY frame.
> 
> Since we do a datagram_poll() already earlier to pick up a mask that could
> possibly contain POLLIN | POLLRDNORM already (due to NL_MMAP_STATUS_COPY),
> we can skip checking the rx ring entirely.
> 
> In case the kernel is compiled with !CONFIG_NETLINK_MMAP, then all this is
> irrelevant anyway as netlink_poll() is just defined as datagram_poll().
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
