From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: release referenct of ip6_null_entry's dst entry
 in __ip6_del_rt
Date: Fri, 21 Sep 2012 13:16:52 -0400 (EDT)
Message-ID: <20120921.131652.353726055575103840.davem@davemloft.net>
References: <1348118734-2967-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609Ab2IURQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:16:54 -0400
In-Reply-To: <1348118734-2967-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 20 Sep 2012 13:25:34 +0800

> as we hold dst_entry before we call __ip6_del_rt,
> so we should alse call dst_release not only return
> -ENOENT when the rt6_info is ip6_null_entry.
> 
> and we already hold the dst entry, so I think it's
> safe to call dst_release out of the write-read lock.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

I cannot find a code path where we can actually end up
with an ip6_null_entry here and I'd much rather declare
this condition as a bug.

Patrick McHardy added this check back in 2006:

	commit 6c813a7297e3af4cd7c3458e09e9ee3d161c6830
	Author: Patrick McHardy <kaber@trash.net>
	Date:   Sun Aug 6 22:22:47 2006 -0700

	    [IPV6]: Fix crash in ip6_del_rt

But the ipv6 code has changed substantially since then.
