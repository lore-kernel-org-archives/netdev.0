From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ircomm: release tty before sleeping potentially
 indefintely
Date: Sun, 03 Mar 2013 17:47:39 -0500 (EST)
Message-ID: <20130303.174739.1195645942179862011.davem@davemloft.net>
References: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, gregkh@linuxfoundation.org, jslaby@suse.cz,
	peter@hurleysoftware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab3CCWrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 17:47:43 -0500
In-Reply-To: <1362350153-26225-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sun,  3 Mar 2013 17:35:53 -0500

> ircomm_tty_block_til_ready would hold tty lock while blocking. Since the sleep
> might take a long time we can prevent other processes from accessing the tty,
> causing hung tasks and a dead tty.
> 
> Diagnosed-by: Peter Hurley <peter@hurleysoftware.com>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

But then you invalidate all of the tty state tests made under
the lock at the beginning of this function, before enterring
the loop.  If you drop the lock, those pieces of state could
change.

I'm not applying this.
