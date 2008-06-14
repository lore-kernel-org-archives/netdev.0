From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: page allocation failure
Date: Sat, 14 Jun 2008 10:58:45 +0400
Message-ID: <20080614065845.GB32585@2ka.mipt.ru>
References: <20080614022451.M72462@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43223 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbYFNG6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 02:58:47 -0400
Content-Disposition: inline
In-Reply-To: <20080614022451.M72462@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 14, 2008 at 05:25:59AM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> I am not sure it is error, but this message appearing on loaded PC routers.
> (about 100-150Mbit/s passing there, and rtorrent also running, 1G of ram)
> 
> For example:
> [1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
> [1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
> [1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
> [1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
> [1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
> [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> [1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
> [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> [1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]

It should be harmless. It means that bnx2 does not support jumbo frames
separated into multiple pages and tries to allocate single huge area.


-- 
	Evgeniy Polyakov
