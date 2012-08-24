From: Cong Wang <amwang@redhat.com>
Subject: Q: what protects dev->napi_list?
Date: Fri, 24 Aug 2012 17:46:44 +0800
Message-ID: <1345801604.11584.24.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758518Ab2HXJqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 05:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sylvain reported a netpoll CPU stall
http://marc.info/?l=linux-netdev&m=134563282530588&w=2

I tried to provide some fix for it:
http://marc.info/?l=linux-netdev&m=134571069921429&w=2

When reviewing that code, I noticed a problem, it seems dev->napi_list
is not protected by any lock? What if the device driver calls
netif_napi_del() meanwhile we are iterating &dev->napi_list in
poll_napi()? It seems netif_napi_del()/netif_napi_add() are usually
called with the RTNL lock held during driver init/uninit, but again
poll_napi() doesn't have RTNL lock.

Am I missing anything?

Thanks!
