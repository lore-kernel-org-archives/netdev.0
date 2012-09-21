From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: remove unnecessary call
 rt6_clean_expires
Date: Fri, 21 Sep 2012 13:19:48 -0400 (EDT)
Message-ID: <20120921.131948.1085353386239998747.davem@davemloft.net>
References: <1348119118-23416-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681Ab2IURTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:19:51 -0400
In-Reply-To: <1348119118-23416-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 20 Sep 2012 13:31:58 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> the from of dst_entry and rt6i_flags of rt6_info have been zeroed out in
> ip6_blackhole_route or after calling ip6_dst_alloc, so it is unnecessary
> to call rt6_clean_expires again.
> 
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

I still don't like this change.

The rt6_clean_expires() calls actually do some work (clear the
RTF_EXPIRES) bit in two of the cases you are changing.

And more importantly, having the rt6_clean_expires() call makes
it easier to audit and make sure this is handled in all the
necessary situations.

The whole point of having an abstracted helper function is so
that we don't have code directly manipulating RTF_EXPIRES.

I'm not applying this patch, sorry.
