From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 12:31:31 +0400
Message-ID: <20080514083131.GA31506@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <20080513233341.47edea7f.akpm@linux-foundation.org> <20080514074028.GA28330@2ka.mipt.ru> <20080514010101.8ef541b3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514010101.8ef541b3.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 01:01:01AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > When ->writepage() is used, it has to wait until page is written (remote
> > side sent acknowledge), so if multiple pages are being written
> > simultaneously we either have to allocate shared structure or use
> > per-page wait.
> 
> That sounds exactly like wait_on_page_writeback()?

Except that we can interrupt waiting and have a timeout, which is
allowed there (page will be unlocked sometime in the future, but we
return error now).

> > Will lock_page_killable()/__lock_page_killable() be exported to modules?
> 
> Maybe, if there's a need.  I see no particular problem with that.

Every good boys, who write own ->writepages() and locks pages there,
want that.

-- 
	Evgeniy Polyakov
