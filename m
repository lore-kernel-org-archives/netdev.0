From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gianfar: Implement workaround for eTSEC74 erratum
Date: Wed, 30 Jun 2010 11:37:06 -0700 (PDT)
Message-ID: <20100630.113706.133400770.davem@davemloft.net>
References: <20100629205959.GA10905@oksana.dev.rtsoft.ru>
	<20100629.151626.90794001.davem@davemloft.net>
	<20100630163804.GA636@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred.rudigier@omicron.at, Sandeep.Kumar@freescale.com,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55559
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754805Ab0F3Sgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 14:36:53 -0400
In-Reply-To: <20100630163804.GA636@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Wed, 30 Jun 2010 20:38:04 +0400

> On Tue, Jun 29, 2010 at 03:16:26PM -0700, David Miller wrote:
>> 
>> I really don't see any value at all to this config option,
>> the errata fixup code should be there all the time.
> 
> Well, at least for eTSEC76 erratum (patch 2/3) we have to touch
> fast path (i.e. start_xmit), so I just wanted to make zero
> overhead for controllers that don't need any fixups.
> 
> Not that there's much of the overhead in a single additional
> 'if' condition, no. ;-)

The register accesses will dominate the costs with this chip.

The only case where a if() test is going to potentially create
some practical performance impact is if the TX is performed
purely using changes to a shared memory data structure and
absolutely no MMIO register reads or writes.
