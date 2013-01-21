From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 21:16:32 +0900
Message-ID: <50FD31A0.5080003@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FCE228.3090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50035 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753055Ab3AUMQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:16:35 -0500
In-Reply-To: <50FCE228.3090801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
>> [ARP and NDISC]
>> - both can be handled in more natural way.
>> -- You will not need to mangle those packets when
>>     sending/receiving.
> 
> This is also true if we introduce a function pointer. My last implementation does not mangle packets in the driver.
> 
>> -- You do not need to inspect ARP/NDISC packet.
>>     By using netevent notification mechanism, you can
>>     learn peer parameters.
> 
> That is worth to investigate. Will I get notifications when a ARP/NDISC will be send or only if the stack received ARP/NDISC packets? However, I can't see how this will help to get the firewire specific information into the ARP/NDISC packet. This has to be done either via the suggested function pointer or your extension of the mac address.

Netevent example: drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:netevent_cb().
It will be notified when NCE has been updated (by ARP/NDP, in most cases).

Yes, it is for learning Uniq-ID and FIFO from peer.

To send our Uniq-ID and FIFO to peer via ARP/NDP, I am proposing to use
extended MAC.  This will also help MCAP implementation, without big change
in IPv4/IPv6 or even whole net stack.

--yoshfuji
