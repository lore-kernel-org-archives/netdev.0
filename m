From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 15:39:18 +0100
Message-ID: <20140811143918.GI3249@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
 <53E8B2A4.9070008@citrix.com>
 <20140811134847.GF3249@zion.uk.xensource.com>
 <53E8CBF5.1030600@citrix.com>
 <20140811143107.GH3249@zion.uk.xensource.com>
 <53E8D488.1020305@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7244 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753235AbaHKOjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 10:39:20 -0400
Content-Disposition: inline
In-Reply-To: <53E8D488.1020305@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2014 at 03:34:48PM +0100, David Vrabel wrote:
[...]
> >>
> >> And cleaning it up a bit (the while() could be a for(;;)).
> >>
> > 
> > Unfortunately this approach is bogus. If xenbus thread is not blocked it
> > can free up various resources while dealloc thread is running -- queue
> > can be gone under dealloc thread's feet.
> 
> kthread_stop() waits until the thread exits (like pthread_join()).
> 
> /**
>  * kthread_stop - stop a thread created by kthread_create().
>  * @k: thread created by kthread_create().
>  *
>  * Sets kthread_should_stop() for @k to return true, wakes it, and
>  * waits for it to exit.
> 

Ah, misremeber the behaviour of kthread_stop. Sorry for the noise.

Wei.

> David
