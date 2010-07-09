From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.35-rc3] ks8842 driver
Date: Thu, 08 Jul 2010 21:41:01 -0700 (PDT)
Message-ID: <20100708.214101.39178389.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D0212A4@MELANITE.micrel.com>
	<20100708075245.GA21371@verge.net.au>
	<C43529A246480145B0A6D0234BDB0F0D481D67@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org, Charles.Li@Micrel.Com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57101
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750936Ab0GIEkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 00:40:46 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D481D67@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Thu, 8 Jul 2010 12:01:51 -0700

> The original ks8842 driver is designed to work on the customized bus
> interface based on an FPGA. This patch is intended to address the more
> commonly used generic bus interface available on the majority of SoC in
> the market.
> 
> It is unlikely that for a system to use both FPGA based and generic bus
> interface for ks8842, I am quite certain that those 2 devices are used
> mutual exclusively.

Like Simon, I'm not to thrilled with this approach.

Any flag bit test you'd need to add to the driver to handle both cases
will have zero performance impact since the cost of the MMIO accesses
will dominate such tests entirely.

Add a boolean flag bit to the driver software state, set it based upon
some platform_device private setting, and test it in these paths to
device what to do.

As a bonus, anyone who enables this driver at all in their build will
test the compilation of both code paths.  And to me, that extra
compilation testing trumps whatever arguments you may make for not
making this support dynamic.

Thanks.
