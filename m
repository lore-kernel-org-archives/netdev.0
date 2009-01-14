From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Wed, 14 Jan 2009 12:48:29 +0100
Message-ID: <20090114114829.GI8625@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com> <20090110231127.GK17917@elte.hu> <20090114114401.GL20283@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57815 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755900AbZANLtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 06:49:08 -0500
Content-Disposition: inline
In-Reply-To: <20090114114401.GL20283@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Sun, Jan 11, 2009 at 12:11:27AM +0100, Ingo Molnar wrote:
> > 
> > * Joerg Roedel <joerg.roedel@amd.com> wrote:
> > 
> > > +#define err_printk(dev, format, arg...) do {			\
> > > +		error_count += 1;				\
> > > +		if (show_all_errors || show_num_errors > 0) {	\
> > > +			WARN(1, "%s %s: " format,		\
> > > +			     dev_driver_string(dev),		\
> > > +			     dev_name(dev) , ## arg);		\
> > > +		}						\
> > > +		if (!show_all_errors && show_num_errors > 0)	\
> > > +			show_num_errors -= 1;			\
> > 
> > Note that the arithmetics here is SMP-unsafe: we only hold the hash bucket 
> > so if two errors hit at once on two CPUs then the error tracking variables 
> > can be accessed at once.
> > 
> > I'd suggest a simple global lock for this error case (taken inside the 
> > hash bucket lock), to be on the safe side.
> 
> As I wrote in a previous email, a race here is no big deal. I add a 
> comment to document it. Or do we want another global lock here?

we commonly use global locks in debug exception cases - to serialize 
console output. But it's certainly no big deal.

	Ingo
