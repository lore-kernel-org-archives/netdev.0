From: Sage Weil <sage@newdream.net>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 06:41:53 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805140638450.14334@cobra.newdream.net>
References: <20080513174523.GA1677@2ka.mipt.ru> <20080513233341.47edea7f.akpm@linux-foundation.org>
 <20080514074028.GA28330@2ka.mipt.ru> <20080514080801.GE28330@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cobra.newdream.net ([66.33.216.30]:56046 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbYENNly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 09:41:54 -0400
In-Reply-To: <20080514080801.GE28330@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, May 14, 2008 at 11:40:28AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > If any thread takes more than one kmap() at a time, it is deadlockable.
> > > Because there is a finite pool of kmaps.  Everyone can end up holding
> > > one or more kmaps, then waiting for someone else to release one.
> > 
> > It never takes the whole LAST_PKMAP maps. So the same can be applied to
> > any user who kmaps at least one page - while user waits for free slot,
> > it can be reused by someone else and so on.
> 
> Actually CIFS uses the same logic: maps multiple pages in wrteback path
> and release them after received reply.

Yes.  Only a pagevec at a time, though... apparently 14 is a small enough 
number not to bite too many people in practice?

sage
