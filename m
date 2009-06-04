From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: No more expensive sock_hold()/sock_put() on each
 tx
Date: Thu, 04 Jun 2009 02:26:44 -0700 (PDT)
Message-ID: <20090604.022644.20820407.davem@davemloft.net>
References: <4A275380.1050601@gmail.com>
	<20090603.215621.136203134.davem@davemloft.net>
	<4A27916B.7030607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43351
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbZFDJ0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 05:26:43 -0400
In-Reply-To: <4A27916B.7030607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Jun 2009 11:18:35 +0200

> Next step would be to get rid of sk_callback_lock, I dont remember
> if we already discussed about that rwlock, after RCUification of sockets...

We discussed it, but the RCU'ification of core socket destruction
is pretty expensive.  Just do any simple connection rate based
test, like lat_connection from lmbench, and the effects are clear.
