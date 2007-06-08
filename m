From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Thu, 07 Jun 2007 18:47:31 -0700 (PDT)
Message-ID: <20070607.184731.10907840.davem@davemloft.net>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932072AbXFHBrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:47:15 -0400
In-Reply-To: <E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 06 Jun 2007 10:08:29 +0200

> There are races involving the garbage collector, that can throw away
> perfectly good packets with AF_UNIX sockets in them.
> 
> The problems arise when a socket goes from installed to in-flight or
> vice versa during garbage collection.  Since gc is done with a
> spinlock held, this only shows up on SMP.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

I'm going to hold off on this one for now.

Holding all of the read locks kind of defeats the purpose of using
the per-socket lock.

Can't you just lock purely around the receive queue operation?
