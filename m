From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 18:47:28 -0500
Message-ID: <20060816234728.GP20551@austin.ibm.com>
References: <44E34825.2020105@garzik.org> <200608162324.47235.arnd@arndb.de> <20060816225558.GM20551@austin.ibm.com> <200608170103.21097.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org, jeff@garzik.org,
	netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33439 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S932123AbWHPXsa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 19:48:30 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200608170103.21097.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2006 at 01:03:20AM +0200, Arnd Bergmann wrote:
> 
> Could well be related to latencies when going to the remote
> node for descriptor DMAs. Have you tried if the hch's NUMA
> patch or using numactl makes a difference here?

No. I guess I should try.

> > > sounds like the right approach to simplify the code.
> >
> > Its not a big a driver. 'wc' says its 2.3 loc, which
> > is 1/3 or 1/5 the size of tg3.c or the e1000*c files.
> 
> Right, I was thinking of removing a lock or another, not
> throwing out half of the driver ;-)

There's only four lock points grand total. 
-- One on the receive side,
-- one to protect the transmit head pointer, 
-- one to protect the transmit tail pointer, 
-- one to protect the location of the transmit low watermark.

The last three share the same lock. I tried using distinct
locks, but this worsened things, probably due to cache-line 
trashing. I tried removing the head pointer lock, but this
failed. I don't know why, and was surprised by this. I thought
hard_start_xmit() was serialized.

--linas
