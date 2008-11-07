From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 07 Nov 2008 11:54:01 -0800 (PST)
Message-ID: <20081107.115401.214017400.davem@davemloft.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
	<20081107084555.GA13347@ioremap.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: yavor@simplifymedia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750940AbYKGTyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 14:54:02 -0500
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887F@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Fri, 7 Nov 2008 11:38:14 -0500

> It would change. Switching the bucket allows you to grow the table
> size and keep O(1).  Without changing the hash function, growing the
> table size will not help.  Currently all binds on the same port will
> go to the same bucket.

I hear a lot of talk about a "new hash function" but what in the world are you
going to hash on other than the port?

Listening sockets can bind to just a specific port, with source and
destination address set to "ANY" (ie. wildcard).

Therefore, if you use some idea like using saddr or daddr in the hash
function, then a listening socket bind will have to walk the entire table
to see if any socket exists already bound to that port.

You really lack some fundamental understanding of the code you are trying
to change, and the things that code must cater to.
