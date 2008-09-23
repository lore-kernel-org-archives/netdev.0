From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 04:30:05 -0700
Message-ID: <20080923043005.358e19e7.akpm@linux-foundation.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
	<20080923104026.GA12535@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org, andi@firstfloor.org,
	ak@linux.intel.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41196 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbYIWLav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 07:30:51 -0400
In-Reply-To: <20080923104026.GA12535@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008 06:40:26 -0400 Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Sep 22, 2008 at 02:51:03PM -0700, akpm@linux-foundation.org wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > 
> > - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
> 
> > -static loff_t
> > -mISDN_llseek(struct file *filep, loff_t offset, int orig)
> > -{
> > -	return -ESPIPE;
> > -}
> 
> >  static struct file_operations mISDN_fops = {
> > -	.llseek		= mISDN_llseek,
> 
> This is wrong.  no llseek means we use default_llseek, which is
> different from returning -ESPIPE.

so.. this?

--- a/drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes-fix
+++ a/drivers/isdn/mISDN/timerdev.c
@@ -61,7 +61,7 @@ mISDN_open(struct inode *ino, struct fil
 	init_waitqueue_head(&dev->wait);
 	filep->private_data = dev;
 	__module_get(THIS_MODULE);
-	return 0;
+	return nonseekable_open(ino, filep);
 }
 
 static int
_

