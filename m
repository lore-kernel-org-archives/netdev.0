From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v3] xfrm: remove useless hash_resize_mutex locks
Date: Mon, 1 Sep 2014 13:29:44 +0200
Message-ID: <20140901112944.GG6390@secunet.com>
References: <1409303348-23262-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <christophe.gouault@6wind.com>,
	<netdev@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47124 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbaIAL3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 07:29:50 -0400
Content-Disposition: inline
In-Reply-To: <1409303348-23262-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2014 at 05:09:07PM +0800, Ying Xue wrote:
> In xfrm_state.c, hash_resize_mutex is defined as a local variable
> and only used in xfrm_hash_resize() which is declared as a work
> handler of xfrm.state_hash_work. But when the xfrm.state_hash_work
> work is put in the global workqueue(system_wq) with schedule_work(),
> the work will be really inserted in the global workqueue if it was
> not already queued, otherwise, it is still left in the same position
> on the the global workqueue. This means the xfrm_hash_resize() work
> handler is only executed once at any time no matter how many times
> its work is scheduled, that is, xfrm_hash_resize() is not called
> concurrently at all, so hash_resize_mutex is redundant for us.
> 
> Cc: Christophe Gouault <christophe.gouault@6wind.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: David S. Miller <davem@davemloft.net>

Applied to ipsec-next, thanks!
