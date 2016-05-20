From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: sock: move ->sk_shutdown out of bitfields.
Date: Fri, 20 May 2016 18:05:52 -0400 (EDT)
Message-ID: <20160520.180552.293412690344388226.davem@davemloft.net>
References: <1463585471.18194.123.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463588367-16310-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, rweikusat@mobileactivedefense.com,
	edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: aryabinin@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcETWFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 18:05:54 -0400
In-Reply-To: <1463588367-16310-1-git-send-email-aryabinin@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Wed, 18 May 2016 19:19:27 +0300

> ->sk_shutdown bits share one bitfield with some other bits in sock struct,
> such as ->sk_no_check_[r,t]x, ->sk_userlocks ...
> sock_setsockopt() may write to these bits, while holding the socket lock.
> 
> In case of AF_UNIX sockets, we change ->sk_shutdown bits while holding only
> unix_state_lock(). So concurrent setsockopt() and shutdown() may lead
> to corrupting these bits.
> 
> Fix this by moving ->sk_shutdown bits out of bitfield into a separate byte.
> This will not change the 'struct sock' size since ->sk_shutdown moved into
> previously unused 16-bit hole.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied and queued up for -stable.

Thanks.
