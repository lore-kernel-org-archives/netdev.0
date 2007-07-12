From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] rewrite AF_UNIX garbage collector, fixes race
Date: Wed, 11 Jul 2007 19:29:40 -0700 (PDT)
Message-ID: <20070711.192940.21926073.davem@davemloft.net>
References: <E1I61UT-0006Gk-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47595
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760777AbXGLC3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:29:17 -0400
In-Reply-To: <E1I61UT-0006Gk-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 04 Jul 2007 11:49:41 +0200

> Throw out the old mark & sweep garbage collector and put in a
> refcounting cycle detecting one.
> 
> The old one had a race with recvmsg, that resulted in false positives
> and hence data loss.  The old algorithm operated on all unix sockets
> in the system, so any additional locking would have meant performance
> problems for all users of these.
> 
> The new algorithm instead only operates on "in flight" sockets, which
> are very rare, and the additional locking for these doesn't negatively
> impact the vast majority of users.
> 
> In fact it's probable, that there weren't *any* heavy senders of
> sockets over sockets, otherwise the above race would have been
> discovered long ago.
> 
> The patch works OK with the app that exposed the race with the old
> code.  The garbage collection has also been verified to work in a few
> simple cases.
> 
> See comments inside patch for the description of the algorithm.
> 
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>

This looks good, patch applied and I'll get this into the
2.6.23 merge window.

Once this sits around for a while and we feel super-confident
with it we can consider a backport into -stable.

