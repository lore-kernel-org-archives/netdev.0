From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 09:23:46 -0700 (PDT)
Message-ID: <20120718.092346.1263036873056516097.davem@davemloft.net>
References: <1342564781.2626.1264.camel@edumazet-glaptop>
	<20120717234037.GA26972@electric-eye.fr.zoreil.com>
	<AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab2GRQXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:23:47 -0400
In-Reply-To: <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Wed, 18 Jul 2012 14:45:55 +0800

> Francois Romieu [mailto:romieu@fr.zoreil.com] 
> [...]
> 
>> Hayes, should we not add into the kernel driver something similar to
>> the rtl8168_start_xmit::skb_checksum_help stuff in Realtek's 
>> 8168 driver ?
>> There seems to be a bug for (skb->len < 60 && RTL_GIGA_MAC_VER_34.
> 
> For RTL8168E-VL (RTL_GIGA_MAC_VER_34), the hardware wouldn't send the packet
> with the length less than 60 bytes. The hardware should pad this kind of packet
> to 60 bytes, but it wouldn't. Therefore, the software has to pad the packet to
> 60 bytes. However, the hw checksum would be incorrect for the modified packet,
> so the software checksum is necessary.

I wonder how the hardware checksum can be incorrectly calculated if the padding
is done with zeros?
