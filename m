From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 10:31:40 -0700
Message-ID: <20080923103140.402cd9e7.akpm@linux-foundation.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
	<20080923104026.GA12535@infradead.org>
	<20080923043005.358e19e7.akpm@linux-foundation.org>
	<20080923114530.GA568@infradead.org>
	<20080923120029.GA14012@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	andi@firstfloor.org, ak@linux.intel.com
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52209 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752468AbYIWRck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 13:32:40 -0400
In-Reply-To: <20080923120029.GA14012@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008 14:00:30 +0200 Karsten Keil <kkeil@suse.de> wrote:

> On Tue, Sep 23, 2008 at 07:45:34AM -0400, Christoph Hellwig wrote:
> > On Tue, Sep 23, 2008 at 04:30:05AM -0700, Andrew Morton wrote:
> > > so.. this?
> > 
> > Much better.
> > 
> > > --- a/drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes-fix
> > > +++ a/drivers/isdn/mISDN/timerdev.c
> > > @@ -61,7 +61,7 @@ mISDN_open(struct inode *ino, struct fil
> > >  	init_waitqueue_head(&dev->wait);
> > >  	filep->private_data = dev;
> > >  	__module_get(THIS_MODULE);
> > > -	return 0;
> > > +	return nonseekable_open(ino, filep);
> > 
> > But this also shows that mISDN is kinda stuck in a different century.
> > Doing __module_get(THIS_MODULE) at the end of ->open is utterly racy,
> > it really needs to set a owner field in file_operations and rip this
> > cruft out.
> > 
> > Btw, can anyone explain WTF this timerdev module is doing?  It's not
> > using any functionality from the rest of mISDN, it's not exporting
> > any functionality to it either but just provides a really awkward way
> > to expose dumb timers to userspace.  What does it provide that the
> > normal timer syscalls can't provide?
> 
> This version only makes the programing of upper ISDN layers easier,
> you only need to watch /dev/mISDNtimer together with the sockets in one
> select call.

sys_timerfd_create() can do this?

> The next version will have a option to synchronise the timer with
> the ISDN hardware clock which would avoid additional jitter if you need to
> bridge channels in software.

hrm.  If that's really really useful and actually works then I guess it
might then be justifiable.

