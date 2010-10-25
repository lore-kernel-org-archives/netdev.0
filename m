From: Ben Greear <greearb@candelatech.com>
Subject: Question on code in __netif_receive_skb
Date: Mon, 25 Oct 2010 14:37:00 -0700
Message-ID: <4CC5F87C.7060302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44692 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab0JYVhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:37:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While poking at the VLAN crash, I noticed this code in dev.c, in
the __netif_receive_skb method.

	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
		return NET_RX_SUCCESS;

As far as I can tell, this return can never happen because vlan_hwaccel_do_receive
always returns 0.

Maybe it should instead check for return-value == 0 and return success in that case?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

