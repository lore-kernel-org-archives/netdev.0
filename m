From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 1/3] xen-netback: page pool support
Date: Fri, 24 May 2013 14:25:46 +0100
Message-ID: <20130524132546.GC16745@zion.uk.xensource.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
 <1369391553-16835-2-git-send-email-wei.liu2@citrix.com>
 <519F60AF.5020705@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25980 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755904Ab3EXNaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 09:30:08 -0400
Content-Disposition: inline
In-Reply-To: <519F60AF.5020705@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 01:44:31PM +0100, David Vrabel wrote:
> On 24/05/13 11:32, Wei Liu wrote:
> > This patch implements a page pool for all vifs. It has two functionalities:
> >  a) to limit the amount of pages used by all vifs
> >  b) to track pages belong to vifs
> 
> This adds a global spin lock.  This doesn't seem very scalable.
> 

Well we already have a bunch of spin locks in Linux's page allocator.
This spin lock protects a very small critical section which looks quite
acceptable to me.

> It's also not clear how this is usefully limiting the memory usage by
> guest network traffic.  It limits the number of pages that netback can
> use during the grant copy from the guest pages but this is only short
> time compared to the lifetime of the network packet within the rest of
> the network stack.
> 

Please consider we might have some sort of mapping mechanism in the
future, that's when page pool becomes able to actually limit number of
pages used by vifs.

> If you didn't have this page pool stuff then each thread/VIF is limited
> to at most 256 pages anyway and I think 1 MiB of memory per VIF is
> perfectly acceptable.
> 

Please note that 256 is only the current status, we might need to
tune this number in the future.

I would like to have more input on this.


Wei.

> David
