From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 02:48:07 -0700 (PDT)
Message-ID: <20070618.024807.45712241.davem@davemloft.net>
References: <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
	<20070618.023520.102546505.davem@davemloft.net>
	<E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54698
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753400AbXFRJrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 05:47:49 -0400
In-Reply-To: <E1I0DmJ-0006yg-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 11:44:07 +0200

> > Secondarily, this bug has been around for years and nobody noticed.
> > The world will not explode if this bug takes a few more days or
> > even a week to work out.  Let's do it right instead of ramming
> > arbitrary turds into the kernel.
> 
> Fine, but just wishing a bug to get fixed won't accomplish anything.
> I've spent a fair amount of time debugging this thing, and I'm out of
> ideas.  Really.  So unless somebody steps up to look at this, it won't
> _ever_ get fixed.

Somone just needs to find a way to only lock the socket as it is
being operated upon.

The race you are dealing with is rather simple, the queue check
and the state check need to be done atomically.  The only chore
is to find a way to make that happen in the context of what the
garbage allocator is trying to do.

I'm not even convinced that your most recent attempt is deadlock free.
Locking multiple objects the same way all at once like that is
something that needs to be seriously audited.
