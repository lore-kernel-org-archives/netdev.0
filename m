From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 16:29:53 +0200
Message-ID: <200609181629.53949.ak@suse.de>
References: <p73k6414lnp.fsf@verdi.suse.de> <p73eju94htu.fsf@verdi.suse.de> <20060918.070905.98863400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: master@sectorb.msk.ru, hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:62619 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S965229AbWIRO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 10:29:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060918.070905.98863400.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> People who run tcpdump want "wire" timestamps as close as possible.
> Yes, things get delayed with the IRQ path, DMA delays, IRQ
> mitigation and whatnot, but it's an order of magnitude worse if
> you delay to user read() since that introduces also the delay of
> the packet copies to userspace which are significantly larger than
> these hardware level delays.  If tcpdump gets swapped out, the
> timestamp delay can be on the order of several seconds making it
> totally useless.

My proposal wasn't to delay to user read, just to do the time stamp in socket 
context. This means as soon as packet or RAW/UDP have looked up the socket and can 
check a per socket flag do the time stamp.

The only delay this would add would be the queueing time from the NIC
to the softirq. Do you really think that is that bad?

-Andi
