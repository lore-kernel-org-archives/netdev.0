From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4]: powerpc/cell spidernet low watermark patch.
Date: Sat, 19 Aug 2006 14:33:42 +1000
Message-ID: <1155962022.5803.68.camel@localhost.localdomain>
References: <20060818192356.GD26889@austin.ibm.com>
	 <20060818.142513.29571851.davem@davemloft.net>
	 <20060818224618.GN26889@austin.ibm.com>
	 <20060818.155116.112621100.davem@davemloft.net>
	 <20060818232942.GO26889@austin.ibm.com>
	 <20060818234532.GA8644@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jens.Osterkamp@de.ibm.com, jklewis@us.ibm.com, arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52197 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S932086AbWHSEeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2006 00:34:14 -0400
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060818234532.GA8644@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-18 at 18:45 -0500, Linas Vepstas wrote:
> On Fri, Aug 18, 2006 at 06:29:42PM -0500, linas wrote:
> > 
> > I don't understand what you are saying. If I call the transmit 
> > queue cleanup code from the poll() routine, nothing hapens, 
> > because the kernel does not call the poll() routine often 
> > enough. I've stated this several times.  
> 
> OK, Arnd gave me a clue stick. I need to call the (misnamed)
> netif_rx_schedule() from the tx interrupt in order to get 
> this to work. That makes sense, and its easy, I'll send the 
> revised patch.. well, not tonight, but shortly.

You might not want to call it all the time though... You need some
interrupt mitigation and thus a timer that calls netif_rx_schedule()
might be of some use still...

Ben.


