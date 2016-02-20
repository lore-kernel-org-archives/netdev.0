From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 5/5] nfp: don't trust netif_running() in debug
 code
Date: Sat, 20 Feb 2016 00:01:45 -0500 (EST)
Message-ID: <20160220.000145.1464068847848293405.davem@davemloft.net>
References: <1455827893-26366-1-git-send-email-jakub.kicinski@netronome.com>
	<1455827893-26366-6-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcBTFBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 00:01:47 -0500
In-Reply-To: <1455827893-26366-6-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 18 Feb 2016 20:38:13 +0000

> Since change_mtu() can fail and leave us with netif_running()
> returning true even though all rings were freed - we should
> look at NFP_NET_CFG_CTRL_ENABLE flag to determine if device
> is really opened.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

This is exactly why I don't like how you are doing your MTU change at
all.

You must not make the device inoperative if you simply cannot perform
the MTU change.  I'm pretty sure I've told you this already, this
whole ->close(), MTU change, ->open() OOPS THAT FAILED sequence is a
non-starter.  You can't do this.

You are leaving the netdev object in an illegal state when this
happens.

You must return from ->change_mtu() with the device in the UP
and running state if you cannot make the MTU change.

I don't care how invasive it is, you must fix this properly if
you want to fix this because as-is this patch series is a cure
worse than the disease.

I'm not applying any of your currently submitted changes, both for net
and net-next, sorry.
