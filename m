From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sockopt: Introduce the SO_BINDTOIFINDEX
Date: Tue, 23 Oct 2012 13:36:02 -0400 (EDT)
Message-ID: <20121023.133602.1844873902881466397.davem@davemloft.net>
References: <5086A7FD.3020503@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531Ab2JWRgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:36:05 -0400
In-Reply-To: <5086A7FD.3020503@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is really a huge ball of confusion.

The user asks for a device to bind to, and they want the device which
had a particular name at the time of the call.

If you allow setting this via ifindex, the issues and races are the
same whether the name-->ifindex translation is done before the
sockopt() call or during it.

Furthermore both the name and the ifindex can change (that latter
via module unload/load).

If you want me to consider these changes seriously, talk less about
obtuse issues like symmetry and more about what problems it actually
solves.  As far as I can tell, all the same real issues still exist
even if we had this new interface.

In fact, I wouldn't mind if a getsockopt() on SO_BINDTODEVICE returned
BOTH the name and the ifindex in a special structure.  Then you could
actually construct a more foolproof mechanism on the user side to try
various ways to get the same device bound to during restart.

Symmetry is over-rated.
