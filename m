From: Andi Shyti <andi@etezian.org>
Subject: Re: [PATCH] 9p: client: remove unused code and any reference to
 "cancelled" function
Date: Thu, 25 Jul 2013 10:57:38 +0200
Message-ID: <20130725085738.GC4295@jack.whiskey>
References: <20130725061411.GA8579@nautica>
 <1374742464-10686-1-git-send-email-andi@etezian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@etezian.org, dominique.martinet@cea.fr, pebolle@tiscali.nl,
	lucho@ionkov.net, ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from etezian.org ([198.101.225.253]:41835 "EHLO mail.etezian.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab3GYI4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 04:56:14 -0400
Content-Disposition: inline
In-Reply-To: <1374742464-10686-1-git-send-email-andi@etezian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Jul 25, 2013 at 10:54:24AM +0200, Andi Shyti wrote:
> This patch reverts commit
> 
> 80b45261a0b263536b043c5ccfc4ba4fc27c2acc
> 
> which was implementing a 'cancelled' functionality to notify that
> a cancelled request will not be replied.
> 
> This implementation was not used anywhere and therefore removed.

did you mean this?

> -	spin_lock(&c->lock);
>  	if (oldreq->status == REQ_STATUS_FLSH) {
> +		spin_lock(&c->lock);
>  		list_del(&oldreq->req_list);
>  		spin_unlock(&c->lock);
> -		if (c->trans_mod->cancelled)
> -			c->trans_mod->cancelled(c, req);

I just put the spin_lock inside the if statement, so that it
locks only if the statement it's true.

Andi
