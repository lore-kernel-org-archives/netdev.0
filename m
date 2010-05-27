From: David Miller <davem@davemloft.net>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 21:21:05 -0700 (PDT)
Message-ID: <20100526.212105.212688828.davem@davemloft.net>
References: <1274868776.2672.96.camel@edumazet-laptop>
	<20100527035617.GB28295@kryten>
	<1274933926.2542.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751237Ab0E0EU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 00:20:57 -0400
In-Reply-To: <1274933926.2542.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 May 2010 06:18:46 +0200

> Process context :
> 
> lock only (sk_lock.slock = locked, sk_lock.owned = ???)
> 
> So I should add a test on owned. If set (by another thread), we should take the slow path.

Indeed, what you're doing now is broken.

If owned is non-zero when you take the spinlock you have to queue your
work, just like how we toss packets into the socket backlog, which is
processed by release_sock(), when this happens.
