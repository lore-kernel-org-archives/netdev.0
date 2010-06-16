From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p
 packet)
Date: Wed, 16 Jun 2010 17:28:23 +0200
Message-ID: <4C18ED97.3060702@trash.net>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <4C18B898.4000307@trash.net> <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com> <201006161624.12101.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42279 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab0FPP21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 11:28:27 -0400
In-Reply-To: <201006161624.12101.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Wednesday 16 June 2010, Pedro Garcia wrote:
>   
>> Probably a definitive fix would be not to allow the definition of VLAN 0 
>> in 802.1q module and provide some other way to tag priority packets without
>> using a subinterface (maybe in the same module or a new 8021p one). I am 
>> having a look at the kernel to see what happens if we load two modules for 
>> the same protocol. 
>>     
>
> On a related note, we will also need to support 802.1Qad provider bridges
> at some point, which use yet another variation of the VLAN header (actually
> two nested VLAN tags) with a different ethertype.
> I need this for 802.1Qbg multi-channel VEPA (possibly also 802.1Qbh
> port extenders), but I have not yet investigated how to implement this
> in the VLAN module.
>   

Since we don't have any special VLAN handling in the bridging code, I
guess it comes down to optionally using a different ethertype value
(0x88a8) in the VLAN code. We probably also need some indication from
device drivers whether they are able to add these headers to avoid
trying to offload tagging in case they're not.


