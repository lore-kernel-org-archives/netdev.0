From: "Matthias Andree" <matthias.andree@gmx.de>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 18 May 2009 10:02:13 +0200
Message-ID: <op.ut38lzvt1e62zd@merlin.emma.line.org>
References: <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
 <200905111554.50118.elendil@planet.nl>
 <Pine.LNX.4.64.0905111656450.10088@wrl-59.cs.helsinki.fi>
 <20090517.153127.22116458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; delsp=yes; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50454 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751234AbZERICQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 04:02:16 -0400
In-Reply-To: <20090517.153127.22116458.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.05.2009, 00:31 Uhr, schrieb David Miller <davem@davemloft.net>:

> The issue being discussed there is exactly the case where a thread
> is triggering the copied_seq advance in tcp_check_urg() and using
> MSG_PEEK at the same time.
>
> I'm looking more closely into this patch right now, but I might ask
> you to split the two fixes up if I can't convince myself %100 of the
> URG part.  We've already broken URG enough lately :-)

As long as the non-URG part goes into 2.6.30 (it's a regression fix in my  
perception), I'll be a happy camper - at least that would stop the  
kernel's finger pointing at innocent applications. 8-)

OK, I presume an application is innocent if it doesn't use MSG_OOB flags -  
is that sufficient?

-- 
Matthias Andree
