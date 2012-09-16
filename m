From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: skb_linearize
Date: Sun, 16 Sep 2012 12:17:47 +0300
Message-ID: <20120916091747.GA23775@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480Ab2IPJQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Sep 2012 05:16:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I notice that dev_hard_start_xmit might invoke
__skb_linearize e.g. if device does not support NETIF_F_SG.

This in turn onvokes __pskb_pull_tail, and
documentation of __pskb_pull_tail says:
  &sk_buff MUST have reference count of 1.

I am guessing 'reference count' means users in this context, right?
IIUC this is because it modifies skb in a way that
isn't safe if anyone else is looking at the skb.


However, I don't see what guarantees that reference
count is 1 when dev_hard_start_xmit invokes
linearize. In particular it calls dev_queue_xmit_nit
which could queue packets on a network tap.

Could someone help me understand please?

Thanks!

-- 
MST
