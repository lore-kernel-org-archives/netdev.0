From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 16:13:51 +0200
Message-ID: <20080923141351.GH25711@one.firstfloor.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org> <20080923104026.GA12535@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, kkeil@suse.de, netdev@vger.kernel.org,
	andi@firstfloor.org, ak@linux.intel.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:50276 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbYIWOJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 10:09:01 -0400
Content-Disposition: inline
In-Reply-To: <20080923104026.GA12535@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 06:40:26AM -0400, Christoph Hellwig wrote:
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

No it's correct. Character devices don't have FMODE_LSEEK set 
and then no_llseek is the default fallback.

-Andi
-- 
ak@linux.intel.com
