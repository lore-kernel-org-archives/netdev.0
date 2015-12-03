From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: ipv6: restrict hop_limit sysctl setting
 to range [1;255]
Date: Thu, 03 Dec 2015 14:42:37 -0500 (EST)
Message-ID: <20151203.144237.978887160176558314.davem@davemloft.net>
References: <1449006315-11175-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbLCTmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:42:38 -0500
In-Reply-To: <1449006315-11175-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Tue,  1 Dec 2015 22:45:15 +0100

> Setting a value bigger than 255 resulted in using only the lower eight
> bits of that value as it is assigned to the u8 header field. To avoid
> this unexpected result, reject such values.
> 
> Setting a value of zero is technically possible, but hosts receiving
> such a packet have to treat it like hop_limit was set to one, according
> to RFC2460. Therefore I don't see a use-case for that.
> 
> Setting a route's hop_limit to zero in iproute2 means to use the sysctl
> default, which is not the case here: Setting e.g.
> net.conf.eth0.hop_limit=0 will not make the kernel use
> net.conf.all.hop_limit for outgoing packets on eth0. To avoid these
> kinds of confusion, reject zero.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks Phil.
