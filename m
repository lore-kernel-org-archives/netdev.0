From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Wed, 14 May 2008 10:56:54 -0700
Message-ID: <20080514105654.673aee98.akpm@linux-foundation.org>
References: <20080513174523.GA1677@2ka.mipt.ru>
	<20080513233341.47edea7f.akpm@linux-foundation.org>
	<20080514074028.GA28330@2ka.mipt.ru>
	<20080514080801.GE28330@2ka.mipt.ru>
	<Pine.LNX.4.64.0805140638450.14334@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762377AbYENSKd@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805140638450.14334@cobra.newdream.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 May 2008 06:41:53 -0700 (PDT) Sage Weil <sage@newdream.net> wrote:

> > On Wed, May 14, 2008 at 11:40:28AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > If any thread takes more than one kmap() at a time, it is deadlockable.
> > > > Because there is a finite pool of kmaps.  Everyone can end up holding
> > > > one or more kmaps, then waiting for someone else to release one.
> > > 
> > > It never takes the whole LAST_PKMAP maps. So the same can be applied to
> > > any user who kmaps at least one page - while user waits for free slot,
> > > it can be reused by someone else and so on.
> > 
> > Actually CIFS uses the same logic: maps multiple pages in wrteback path
> > and release them after received reply.
> 
> Yes.  Only a pagevec at a time, though... apparently 14 is a small enough 
> number not to bite too many people in practice?
> 

In practice you need a large number of threads performing writeout to
trigger this.  iirc that's how it was demonstrated back in the 2.4
days.  Say, thousands of processes/threads doing write+fsync to
separate files.
