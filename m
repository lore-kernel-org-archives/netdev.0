From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 07:45:34 -0400
Message-ID: <20080923114530.GA568@infradead.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080923104026.GA12535@infradead.org> <20080923043005.358e19e7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, kkeil@suse.de,
	netdev@vger.kernel.org, andi@firstfloor.org, ak@linux.intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39925 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbYIWLp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 07:45:58 -0400
Content-Disposition: inline
In-Reply-To: <20080923043005.358e19e7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:30:05AM -0700, Andrew Morton wrote:
> so.. this?

Much better.

> --- a/drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes-fix
> +++ a/drivers/isdn/mISDN/timerdev.c
> @@ -61,7 +61,7 @@ mISDN_open(struct inode *ino, struct fil
>  	init_waitqueue_head(&dev->wait);
>  	filep->private_data = dev;
>  	__module_get(THIS_MODULE);
> -	return 0;
> +	return nonseekable_open(ino, filep);

But this also shows that mISDN is kinda stuck in a different century.
Doing __module_get(THIS_MODULE) at the end of ->open is utterly racy,
it really needs to set a owner field in file_operations and rip this
cruft out.

Btw, can anyone explain WTF this timerdev module is doing?  It's not
using any functionality from the rest of mISDN, it's not exporting
any functionality to it either but just provides a really awkward way
to expose dumb timers to userspace.  What does it provide that the
normal timer syscalls can't provide?
