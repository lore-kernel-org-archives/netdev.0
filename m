From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] l2tp: fix compile error when CONFIG_IPV6=m
 and CONFIG_L2TP=y
Date: Wed, 19 Sep 2012 16:44:03 -0400 (EDT)
Message-ID: <20120919.164403.1265757047954729748.davem@davemloft.net>
References: <1347947642-20330-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786Ab2ISUoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:44:05 -0400
In-Reply-To: <1347947642-20330-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 18 Sep 2012 13:54:02 +0800

> When CONFIG_IPV6=m and CONFIG_L2TP=y, I got the following compile error:
 ...
> This is due to l2tp uses symbols from IPV6, so when l2tp is
> builtin, IPV6 has to be builtin too.
> 
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

The correct way to express this is:

	depends on (IPV6 || IPV6=n)

Which results in the KCONFIG option only being offers in modes
compatible with the dependency.  Using a 'select' doesn't work
properly in these kinds of cases.

Anyways, grep for that string to see how it is used in other similar
situations.
