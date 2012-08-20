From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: net: ipv6: fix oops in inet_putpeer()
Date: Mon, 20 Aug 2012 02:58:22 -0700 (PDT)
Message-ID: <20120820.025822.875182755255293091.davem@davemloft.net>
References: <Pine.GSO.4.63.1208181729020.7404@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab2HTJ6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:58:23 -0400
In-Reply-To: <Pine.GSO.4.63.1208181729020.7404@stinky-local.trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 18 Aug 2012 17:32:31 +0200 (MEST)

> The attached patch fixes an oops in inet_putpeer(). Please see the
> changelog entry for details.
> 
> An alternative fix would be to check whether rt6_peer_ptr() returns
> NULL before invoking inet_putpeer(), but properly initializing the
> peer looks cleaner to me.

This is fine for now, applied, thanks Patrick.

There was a built-in assumption that xfrm_fill_dst() would run to
completion before we'd try to release these things, because there in
xfrm6_policy.c's xfrm6_fill_dst, we'd do the rt6_transfer_peer().

But that's obviously not the case if errors happen meanwhile.
