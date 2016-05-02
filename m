From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 02 May 2016 16:31:40 -0400 (EDT)
Message-ID: <20160502.163140.11281931277716285.davem@davemloft.net>
References: <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160502191229.GA1946@nanopsycho.orion>
	<1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, edumazet@google.com, netdev@vger.kernel.org,
	eladr@mellanox.com, idosch@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754908AbcEBUbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 16:31:46 -0400
In-Reply-To: <1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 May 2016 13:23:27 -0700

> It looks like net/sunrpc/xprtsock.c should set SOCK_FASYNC
> even if it is not actually using fasync_list
> 
> Could you try this quick hack to check if this is the right way ?

Indeed, it tests the ASYNC bit without enabling FASYNC.

There are three other places that do this: macvtap, tun, dlm lowcomms.
