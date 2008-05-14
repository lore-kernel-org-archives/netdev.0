From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 12:08:01 +0400
Message-ID: <20080514080801.GE28330@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <20080513233341.47edea7f.akpm@linux-foundation.org> <20080514074028.GA28330@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42732 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119AbYENIIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 04:08:13 -0400
Content-Disposition: inline
In-Reply-To: <20080514074028.GA28330@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2008 at 11:40:28AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > If any thread takes more than one kmap() at a time, it is deadlockable.
> > Because there is a finite pool of kmaps.  Everyone can end up holding
> > one or more kmaps, then waiting for someone else to release one.
> 
> It never takes the whole LAST_PKMAP maps. So the same can be applied to
> any user who kmaps at least one page - while user waits for free slot,
> it can be reused by someone else and so on.

Actually CIFS uses the same logic: maps multiple pages in wrteback path
and release them after received reply.

-- 
	Evgeniy Polyakov
