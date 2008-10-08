From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Wed, 08 Oct 2008 13:53:36 +0200
Message-ID: <48EC9F40.3000601@trash.net>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy>	<48EA9223.8090700@trash.net> <48EA964A.6060503@hp.com> <48EA98F0.40302@trash.net> <48EA9CCC.2050505@hp.com> <48EAA05B.20004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47822 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510AbYJHLxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 07:53:39 -0400
In-Reply-To: <48EAA05B.20004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Rick Jones wrote:
>> Does changing the MTU on a physical interface not change the size 
>> frame the NIC itself will be willing to accept?
> 
> IIRC a lot of the simpler ones just use the default eth_setup change_mtu
> callback and the ones that have their one (just had a very brief look at
> sky2, tg3 and e1000) only seem to use it indirectly for enabling jumbo
> frame support and (e1000) memory allocation.
> 
> So I guess what we should do in case of the MTU depends on what we can
> expect from the majority of hardware. If its just some older drivers
> which can be reasonably expected to handle larger frames we should cap
> at the maximum of the real device and maybe introduce the "desired
> mtu" you suggested. It would be useful if people more familiar with
> the drivers and hardware than me could comment on this.

After looking at more drivers, it seems most new ones actually
enfore the configured MTU by programming the hardware with it
(though I don't know the effects this causes) or using it for
memory allocation.

So I think we should follow your suggestions of "desired/operational
MTU". I'll post a patch shortly.

