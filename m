From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 07/11] sfc: Do not pass non-TCP packets into
 GRO code
Date: Thu, 20 Jun 2013 00:18:52 +0100
Message-ID: <1371683932.1956.138.camel@bwh-desktop.uk.level5networks.com>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680396.1956.114.camel@bwh-desktop.uk.level5networks.com>
	 <1371682588.3252.354.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:65257 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934170Ab3FSXS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 19:18:56 -0400
In-Reply-To: <1371682588.3252.354.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 15:56 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-19 at 23:19 +0100, Ben Hutchings wrote:
> > GRO can handle non-TCP packets and pass them up without coalescing,
> > but it has to do some extra work to parse the packet which we can
> > bypass using the hardware parse result.  (Falcon won't mark TCP/IPv6
> > packets as TCP, but then it won't validate their checksums either, so
> > GRO can't coalesce them.)
> 
> Thats not exactly true. GRO can validate the checksums.

OK, maybe that changed at some point.  The original conversions to use
napi_gro_receive() were all conditional on hardware checksum validation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
