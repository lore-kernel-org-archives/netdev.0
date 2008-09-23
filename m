From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Tue, 23 Sep 2008 06:40:26 -0400
Message-ID: <20080923104026.GA12535@infradead.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kkeil@suse.de, netdev@vger.kernel.org, andi@firstfloor.org,
	ak@linux.intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56137 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbYIWKkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 06:40:31 -0400
Content-Disposition: inline
In-Reply-To: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 02:51:03PM -0700, akpm@linux-foundation.org wrote:
> From: Andi Kleen <andi@firstfloor.org>
> 
> - Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.

> -static loff_t
> -mISDN_llseek(struct file *filep, loff_t offset, int orig)
> -{
> -	return -ESPIPE;
> -}

>  static struct file_operations mISDN_fops = {
> -	.llseek		= mISDN_llseek,

This is wrong.  no llseek means we use default_llseek, which is
different from returning -ESPIPE.

