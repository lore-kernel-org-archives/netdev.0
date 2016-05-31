From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Tue, 31 May 2016 11:39:13 -0700 (PDT)
Message-ID: <20160531.113913.1477085966766110028.davem@davemloft.net>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: alan.davey@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcEaSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:39:17 -0400
In-Reply-To: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Davey <alan.davey@metaswitch.com>
Date: Mon, 23 May 2016 15:23:45 +0100

> One of the bugs documented in the raw(7) man page is as follows: When the
> IP_HDRINCL option is set, datagrams will not be fragmented and are limited to
> the interface MTU.
> 
> This patch fixes the bug by removing the check for "length > rt->dst.dev->mtu"
> in raw_send_hdrinc() (net/ipv4/raw.c).  Datagrams are no longer limited to the
> interface MTU size if the IP_HDRINCL option is set, but are fragmented, if
> necessary, in the same way as all other datagrams.
> 
> Signed-off-by: Alan Davey <alan.davey@metaswitch.com>

This is not a bug, it's a feature and it's how RAW ipv4 sockets have behaved
for two decades.

If the user wants to use hdr inclusion, he can send multiple frames and set
the fragmentation bits appropriately.

I'm not applying this patch.
