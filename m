From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 15:12:28 -0700
Message-ID: <5524564C.9090809@redhat.com>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>	 <20150407.155209.47396464487922345.davem@davemloft.net>	 <20150407210248.GC24631@electric-eye.fr.zoreil.com>	 <20150407.172748.700634713750750146.davem@davemloft.net> <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, nix@esperi.org.uk,
	rl@hellgate.ch, gurligebis@gentoo.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbbDGWMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 18:12:31 -0400
In-Reply-To: <1428443685.25985.212.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/07/2015 02:54 PM, Eric Dumazet wrote:
> On Tue, 2015-04-07 at 17:27 -0400, David Miller wrote:
>
>> That's exactly dma_wmb().
>>
>> It barriers cpu writes so that the device sees things in a certain
>> order.
>>
>> It's what all the most common ethernet chip drivers use in their
>> descriptor handling routines now.
> To be fair, only 2 drivers currently use dma_wmb()

Hey, I got at least 4..  :-)  I only got around to patching 3 Intel 
drivers and one RealTek since that is what I had to test with.  I was 
honestly hoping there would be more interest from other developers to 
pick this up and update their drivers to avoid unnecessary barriers but 
it doesn't look like I have had much luck on that front.

Maybe what I can do is submit a set of patches over the next couple of 
weeks to try and update all the spots that either need to have a barrier 
added, such as what is being addressed here, or can have a barrier 
weakened as I have already done for a few other drivers.

- Alex
