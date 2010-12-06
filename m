From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 06 Dec 2010 15:05:15 -0800
Message-ID: <4CFD6C2B.9020201@chelsio.com>
References: <20101206121829.5b8c852e@nehalam>	<4CFD527E.7000706@chelsio.com> <20101206142715.0d296b25@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13284 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0LFXFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 18:05:23 -0500
In-Reply-To: <20101206142715.0d296b25@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 06 Dec 2010 13:15:42 -0800
> Dimitris Michailidis <dm@chelsio.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> I inspected all drivers in net-next to see which drivers are using
>>> LRO and which ones are broken. Most concerning is that Chelsio
>>> and Solarflare drivers ignore ETH_FLAG_LRO.
>>>
>>> The ones that are using LRO but allow disabling it:
>>>   qlcnic, netxen, mv643, s2io, myi10ge, bnx2x, ixgbe, vmxnet3
>>>
>>> One driver seems confused about LRO vs GRO:
>>>   mlx4 - comments about LRO and depends on LRO but driver is using GRO
>>>
>>> Drivers with not using ethtool interface to disable LRO:
>>>   pasemi_mac, sfc, ehea, cxgb3, cxgb4
>> cxgb4 uses GRO, not LRO.
> 
> Ok. but cxgb3 still uses LRO (or it least calls it lro).
> 

cxgb3 was the driver Herbert implemented GRO on I think, and he converted it 
to GRO.  It possibly has leftover LRO references as it was using LRO before.
