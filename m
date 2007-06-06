From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Wed, 06 Jun 2007 01:12:58 -0700 (PDT)
Message-ID: <20070606.011258.71090697.davem@davemloft.net>
References: <E1Hvo2m-00038P-00@dorka.pomaz.szeredi.hu>
	<20070605.224128.104032917.davem@davemloft.net>
	<E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752983AbXFFIMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 04:12:42 -0400
In-Reply-To: <E1HvqZB-0003Vc-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 06 Jun 2007 10:08:29 +0200

> > > > Holding a global mutex over recvmsg() calls under AF_UNIX is pretty
> > > > much a non-starter, this will kill performance for multi-threaded
> > > > apps.
> > > 
> > > That's an rwsem held for read.  It's held for write in unix_gc() only
> > > for a short duration, and unix_gc() should only rarely be called.  So
> > > I don't think there's any performance problem here.
> > 
> > It pulls a non-local cacheline into the local thread, that's extremely
> > expensive on SMP.
> 
> OK, here's an updated patch, that uses ->readlock, and passes my
> testing.

Thanks a lot, I'll review this as soon as possible unless
someone else beats me to it :)
