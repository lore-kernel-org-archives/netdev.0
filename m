From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 16:20:49 -0700
Message-ID: <55246651.3000007@redhat.com>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>	 <20150407.155209.47396464487922345.davem@davemloft.net>	 <20150407210248.GC24631@electric-eye.fr.zoreil.com>	 <20150407.172748.700634713750750146.davem@davemloft.net>	 <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>	 <5524564C.9090809@redhat.com> <1428445367.25985.214.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164AbbDGXVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 19:21:04 -0400
In-Reply-To: <1428445367.25985.214.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/07/2015 03:22 PM, Eric Dumazet wrote:
> On Tue, 2015-04-07 at 15:12 -0700, Alexander Duyck wrote:
>> On 04/07/2015 02:54 PM, Eric Dumazet wrote:
>>> To be fair, only 2 drivers currently use dma_wmb()
>> Hey, I got at least 4..  :-)  I only got around to patching 3 Intel
>> drivers and one RealTek since that is what I had to test with.  I was
>> honestly hoping there would be more interest from other developers to
>> pick this up and update their drivers to avoid unnecessary barriers but
>> it doesn't look like I have had much luck on that front.
> Strange I see only 2 drivers here, and no Intel ones :
>
> # git grep -l dma_wmb drivers/net
> drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> drivers/net/ethernet/realtek/r8169.c
>
> I probably missed something ;)

Yeah, I was thinking of the dma_rmb more than the dma_wmb, they are 
essentially just two sides to the same coin.

dma_rmb - read descriptor status for ownership, then dma_rmb, then if we 
own it process rest of descriptor
dma_wmb - write descriptor fields, then dma_wmb, then update status bit 
to release ownership

A wmb is still needed if a PIO doorbell must be used to notify the 
device of additional descriptors.

- Alex
