From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring
 on skb allocation failures
Date: Sun, 20 Dec 2009 17:54:14 +1100
Message-ID: <20091220065411.GB12552@verge.net.au>
References: <20091219104128.GB20743@verge.net.au>
 <C752C323.1B021%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58586 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbZLTGyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 01:54:17 -0500
Content-Disposition: inline
In-Reply-To: <C752C323.1B021%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 19, 2009 at 05:51:31PM -0800, Scott Feldman wrote:
> On 12/19/09 2:41 AM, "Simon Horman" <horms@verge.net.au> wrote:
> 
> > On Fri, Dec 18, 2009 at 06:09:46PM -0800, Scott Feldman wrote:
> >> for (i = 0; i < enic->rq_count; i++) {
> >> -  err = vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> >> -  if (err) {
> >> +  vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> >> +  /* Need at least one buffer on ring to get going */
> >> +  if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
> >> printk(KERN_ERR PFX
> >> "%s: Unable to alloc receive buffers.\n",
> >> netdev->name);
> >> +   err = -ENOMEM;
> >> goto err_out_notify_unset;
> >> }
> >> }
> > 
> > Also, in the case where a failure occurs for i > 0,
> > it it necessary to unwind the previous rq allocations?
> 
> Sorry Simon, I replied wrongly on this one.  The code only cares if _all_
> allocations failed (i.e. The ring is empty), and takes the err path.  Since
> nothing was allocated, the err path has nothing to cleanup.
> 
> If at lease one skb was allocated, then we don't go down the err path, even
> if not all of the allocations succeeded.  Bottom line is we only need one
> skb on the ring to get the ball rolling.  If we start out with a full
> rings-worth of skbs (the expected case), then that's even better.

Understood. Thanks for the clarification.

