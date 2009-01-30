From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Fri, 30 Jan 2009 14:03:46 -0800 (PST)
Message-ID: <20090130.140346.159984249.davem@davemloft.net>
References: <20090127074048.GA4197@ff.dom.local>
	<20090130.134227.123379239.davem@davemloft.net>
	<20090130215920.GC31355@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, zbr@ioremap.net, herbert@gondor.apana.org.au,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757172AbZA3WEF@vger.kernel.org>
In-Reply-To: <20090130215920.GC31355@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 30 Jan 2009 22:59:20 +0100

> On Fri, Jan 30, 2009 at 01:42:27PM -0800, David Miller wrote:
> > It's cheesy and the SLAB developers will likely barf at the
> > idea, but it would certainly work.
> 
> Maybe that would be enough as a definitive fix for a stable
> release, so that we can go on with deeper changes in newer
> versions ?

Such a check could have performance ramifications, I wouldn't
risk it and already I intend to push Jarek's page allocator
splice fix back to -stable eventually.

> > Back to real life, I think long term the thing to do is to just do the
> > cached page allocator thing we'll be doing after Jarek's socket page
> > patch is integrated, and for best performance the driver has to
> > receive it's data into pages, only explicitly pulling the ethernet
> > header into the linear area, like NIU does.
> 
> Are there NICs out there able to do that themselves or does the
> driver need to rely on complex hacks in order to achieve this ?

Any NIC, even the dumbest ones, can be made to receive into pages.
