From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] ipv6: allow routes to be configured with
 expire values
Date: Fri, 11 Dec 2015 20:21:57 -0500 (EST)
Message-ID: <20151211.202157.2045048466167764855.davem@davemloft.net>
References: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449678473.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbbLLBV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:21:59 -0500
In-Reply-To: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449678473.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 10 Dec 2015 00:27:53 +0800

> Add the support for adding expire value to routes,  requested by
> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
> wants it too.
> 
> add it by using the field rta_expires of rta_cacheinfo
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This is the wrong way to do this.

Currently we only ever dump rta_cacheinfo values to the user.

If we use it to set things, we have to completely consider every
member of that structure as potentially having meaning either
intended by the user or choosen by us in the future.

Therefore it is a poor choice to start using for specifying the
expires value, and some other mechanism such as a new RTNETLINK
attribute, should be used for this.
