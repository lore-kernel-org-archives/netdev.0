From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6pack: fix free memory scribbles
Date: Wed, 06 Jan 2016 01:25:55 -0500 (EST)
Message-ID: <20160106.012555.1410677211527515710.davem@davemloft.net>
References: <20160105115042.8134.4926.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcAFGZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 01:25:57 -0500
In-Reply-To: <20160105115042.8134.4926.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan <gnomes@lxorguk.ukuu.org.uk>
Date: Tue, 05 Jan 2016 11:51:25 +0000

> commit acf673a3187edf72068ee2f92f4dc47d66baed47 fixed a user triggerable free
> memory scribble but in doing so replaced it with a different one that allows
> the user to control the data and scribble even more.
> 
> sixpack_close is called by the tty layer in tty context. The tty context is
> protected by sp_get() and sp_put(). However network layer activity via
> sp_xmit() is not protected this way. We must therefore stop the queue
> otherwise the user gets to dump a buffer mostly of their choice into freed
> kernel pages.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied, thanks Alan.

> +	/* We must stop the queue to avoid potentially scribbling
> +	   on the free buffers. The sp->dead_sem is not sufficient
> +	   to protect us from sp->xbuff access */

Please next time format comments:

	/* Like
	 * this.
	 */

Thanks again!
