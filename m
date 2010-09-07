From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] r8169: add gro support
Date: Tue, 07 Sep 2010 13:47:45 -0700 (PDT)
Message-ID: <20100907.134745.115939406.davem@davemloft.net>
References: <1283834799.2585.476.camel@edumazet-laptop>
	<20100907202445.GA11841@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755201Ab0IGUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 16:47:27 -0400
In-Reply-To: <20100907202445.GA11841@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 7 Sep 2010 22:24:45 +0200

> Eric Dumazet <eric.dumazet@gmail.com> :
>> - Use napi_gro_receive() and vlan_gro_receive()
>> - Enable GRO by default
>> 
>> Tested on a RTL8111/8168 adapter
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Francois Romieu <romieu@fr.zoreil.com>
> [...]
>> @@ -1076,7 +1076,12 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
>>  	int ret;
>>  
>>  	if (vlgrp && (opts2 & RxVlanTag)) {
>> -		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
>> +		u16 vtag = swab16(opts2 & 0xffff);
>> +
>> +		if (polling)
> 
> 		if (likely(polling))
> 
> Otherwise Acked-by: Francois Romieu <romieu@fr.zoreil.com>

I've made this change and applied the patch, thanks guys!
