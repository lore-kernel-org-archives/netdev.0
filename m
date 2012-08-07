From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?= <i@lri.fr>
Subject: Re: Adding routes to another table: no such process
Date: Tue, 7 Aug 2012 17:57:49 +0200
Message-ID: <20120807155749.GA3058@zenon.in.qult.net>
References: <20120807141306.GB32655@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qult.net ([82.238.217.46]:46114 "EHLO qult.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775Ab2HGP5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 11:57:53 -0400
Received: from zenon.in.qult.net ([192.168.128.3])
	by qult.net with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.76)
	(envelope-from <i@lri.fr>)
	id 1SymAJ-00027S-Ng
	for netdev@vger.kernel.org; Tue, 07 Aug 2012 17:57:51 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.76)
	(envelope-from <i@lri.fr>)
	id 1SymAH-000197-Dy
	for netdev@vger.kernel.org; Tue, 07 Aug 2012 17:57:49 +0200
Content-Disposition: inline
In-Reply-To: <20120807141306.GB32655@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 07, 2012 at 04:13:06PM +0200, thus spake Ignacy Gawedzki:
> Hi,
> 
> I'm having a hard time setting some routes on a router and can't find any
> relevant information anywhere, so I resort to asking on this list.
> 
> The router has one interface, say eth0, with configured address 10.0.0.1/32.
> 
> Now I would like to do:
> 
>   ip rule add from 10.0.0.1 table 100
>   ip route add 10.0.0.2/32 dev eth0 table 100
>   ip route add 10.0.0.3/32 via 10.0.0.2 table 100
> 
> but I get
> 
>   RTNETLINK answers: No such process

Okay, I think I got it right, at last.  Apparently it all depends on how the
rules are set up.

The rule to lookup table 100 when the source address is 10.0.0.1 doesn't
concern the general situation of route to 10.0.0.2/32 (for which packets may
have any source address).

The solution in my case is to put

  ip rule add to 10.0.0.0/8 table 100

Cheers,

Ignacy

-- 
:wq!
