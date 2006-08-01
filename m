From: Andi Kleen <ak@suse.de>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 1 Aug 2006 02:31:58 +0200
Message-ID: <200608010231.58339.ak@suse.de>
References: <44C8B0B8.2010408@miyazawa.org> <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:7352 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1030357AbWHAAcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 20:32:21 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060727.183415.104032934.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> If we process these in sequence in software interrupt, everything
> is fine.  Processing of "A" will add the address, and the test
> ping packet "B" will respond properly.
> 
> If you defer "A", everything breaks and the test packet "B" will
> get processed first and not work.

Playing devil's advocate here: if the packets are processed on
two different CPUs then this could also happen and break the test
case.

So the test is probably a bit fragile.

Currently it is unlikely to happen because of interrupt affinity for a 
single device,  but in future with MSI-X support it might not.

I generally agree it's better to keep this in kernel though.

-Andi
