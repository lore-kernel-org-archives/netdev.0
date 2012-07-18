From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 13:28:40 -0700 (PDT)
Message-ID: <20120718.132840.1571938255177607234.davem@davemloft.net>
References: <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw>
	<20120718.092346.1263036873056516097.davem@davemloft.net>
	<20120718201201.GC14149@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755947Ab2GRU2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:28:41 -0400
In-Reply-To: <20120718201201.GC14149@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 18 Jul 2012 22:12:01 +0200

> David Miller <davem@davemloft.net> :
>> From: hayeswang <hayeswang@realtek.com>
>> > Francois Romieu [mailto:romieu@fr.zoreil.com] 
>> > [...]
>> > 
>> >> Hayes, should we not add into the kernel driver something similar to
>> >> the rtl8168_start_xmit::skb_checksum_help stuff in Realtek's 
>> >> 8168 driver ?
>> >> There seems to be a bug for (skb->len < 60 && RTL_GIGA_MAC_VER_34.
>> > 
>> > For RTL8168E-VL (RTL_GIGA_MAC_VER_34), the hardware wouldn't send the packet
>> > with the length less than 60 bytes. The hardware should pad this kind of packet
>> > to 60 bytes, but it wouldn't. Therefore, the software has to pad the packet to
>> > 60 bytes. However, the hw checksum would be incorrect for the modified packet,
>> > so the software checksum is necessary.
>> 
>> I wonder how the hardware checksum can be incorrectly calculated if the padding
>> is done with zeros?
> 
> A part of the apparent problem may stem from the fact that Realtek's 8168
> driver claims a modified length but it does not really skb_padto... 
> 
> Hayes, would the patch below fix the original problem ?

A NETDEV_TX_OK return means we accepted the SKB, it doesn't look like
that's what you are doing in the skb_padto() failure path.
