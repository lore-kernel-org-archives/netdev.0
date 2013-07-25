From: Andi Shyti <andi@etezian.org>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused function
Date: Thu, 25 Jul 2013 10:27:41 +0200
Message-ID: <20130725082741.GB4295@jack.whiskey>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
 <20130725061411.GA8579@nautica>
 <20130725064802.GA12569@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, pebolle@tiscali.nl,
	lucho@ionkov.net, ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andi@etezian.org,
	v9fs-developer@lists.sourceforge.net, rminnich@sandia.gov
To: Dominique Martinet <dominique.martinet@cea.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from etezian.org ([198.101.225.253]:41709 "EHLO mail.etezian.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249Ab3GYI0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 04:26:18 -0400
Content-Disposition: inline
In-Reply-To: <20130725064802.GA12569@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> To be more precise, there's a single call to c->trans_mode->cancelled in
> net/9p/client.c, in p9_client_flush, which is called on subfunction returning
> -ERESTARTSYS... which never happens as far as I could see.
> 
> This will be useful once/if we start working on client recovery, though
> - so the function in itself definitely does interest me, and I guess
> that thinking about I would have preferred to have the hook added rather
> than the function removed.
> But there definitely is no hurry to add this cancelled function till
> then.

I would prefer to NACK my patch, it messes up things more than
fixes.

If we really want to get rid of this function we should
completely revert this patch:

80b45261a0b263536b043c5ccfc4ba4fc27c2acc

otherwise, spread in the code, there will be empty references to
the 'cancelled' function (struct p9_trans_module in transport.h
and the one you mentioned).

I would rather prefer Paul's approach to mine, let's just get rid
of the warning :)

Andi
