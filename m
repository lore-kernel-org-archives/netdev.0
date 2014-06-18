From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Wed, 18 Jun 2014 15:21:53 +0100
Message-ID: <20140618142152.GC20819@zion.uk.xensource.com>
References: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
 <53A19FCA.1090205@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63686 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967046AbaFROWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 10:22:43 -0400
Content-Disposition: inline
In-Reply-To: <53A19FCA.1090205@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 10:18:50AM -0400, Boris Ostrovsky wrote:
> On 06/18/2014 10:09 AM, Wei Liu wrote:
> >The original code uses netdev->real_num_tx_queues to bookkeep number of
> >queues and invokes netif_set_real_num_tx_queues to set the number of
> >queues. However, netif_set_real_num_tx_queues doesn't allow
> >real_num_tx_queues to be smaller than 1, which means setting the number
> >to 0 will not work and real_num_tx_queues is untouched.
> >
> >This is bogus when xenvif_free is invoked before any number of queues is
> >allocated. That function needs to iterate through all queues to free
> >resources. Using the wrong number of queues results in NULL pointer
> >dereference.
> >
> >So we bookkeep the number of queues in xen-netback to solve this
> >problem. The usage of real_num_tx_queues in core driver is to cap queue
> >index to a valid value. In start_xmit we've already guarded against out
> >of range queue index so we should be fine.
> >
> >This fixes a regression introduced by multiqueue patchset in 3.16-rc1.
> 
> 
> David sent a couple of patches earlier today that I have been testing and
> they appear to fix both netfront and netback. (I am waiting for 32-bit to
> finish)
> 
> http://lists.xenproject.org/archives/html/xen-devel/2014-06/msg02308.html
> 

I saw that, but they don't fix this backend bug. Try crashing the guest
before it connects to backend. As I said in commit message:

> >This is bogus when xenvif_free is invoked before any number of queues is
> >allocated. That function needs to iterate through all queues to free

netif_set_real_num_tx_queues will need to be removed anyway.

Wei.
