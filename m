From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X25: Replace BKL in sockopts calls
Date: Mon, 10 May 2010 04:44:48 -0700 (PDT)
Message-ID: <20100510.044448.129759879.davem@davemloft.net>
References: <1273409123.2727.387.camel@ibex>
	<20100509.184658.170123822.davem@davemloft.net>
	<1273467040.2325.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753124Ab0EJLol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:44:41 -0400
In-Reply-To: <1273467040.2325.78.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 May 2010 06:50:40 +0200

> Well, its probably better than lock_kernel() ;)
> 
> qbitincl is a char, I suspect some arches cant store a char in an atomic
> way ? Alpha comes to mind.

True.

> We now have lock_sock_bh()/unlock_sock_bh() for this kind of very short
> sections, where we cant sleep.

Another option is to simply use an atomic bitmask to represent these
booleans instead of a crufty set of chars.
