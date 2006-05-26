From: Andi Kleen <ak@suse.de>
Subject: Re: reminder, 2.6.18 window...
Date: Fri, 26 May 2006 11:52:39 +0200
Message-ID: <200605261152.40101.ak@suse.de>
References: <20060523.182217.59656237.davem@davemloft.net> <20060525032357.4990425f.billfink@mindspring.com> <200605250805.38241.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, Jeff Garzik <jeff@garzik.org>,
	phil@ipom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:9696 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751325AbWEZJwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 05:52:44 -0400
To: Brent Cook <bcook@bpointsys.com>
In-Reply-To: <200605250805.38241.bcook@bpointsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The current patch is fine if your hardware implements the required atomicity 
> itself. 

Near all do optionally, but it would make increasing the statistics a magnitude 
more expensive.

Atomic operations don't come cheap on modern systems. And you would need
to change the fast path increments to atomic for this.

I suspect it could be done without atomics with some tricks (e.g. use a double
set of counters and switch on clear and use RCU), but it would make the whole
thing quite complex and still have more overhead in the fast path than
the current code.

-Andi

