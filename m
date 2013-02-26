From: Bercaru Cristian-B43982 <B43982@freescale.com>
Subject: netif_receive_skb return value in bridging scenario
Date: Tue, 26 Feb 2013 14:57:12 +0000
Message-ID: <675385003F19144A8CE636FC6B7BB7012F25EC@039-SN2MPN1-021.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:25798
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759233Ab3BZO51 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 09:57:27 -0500
Received: from mail166-co1 (localhost [127.0.0.1])	by
 mail166-co1-R.bigfish.com (Postfix) with ESMTP id F019498011A	for
 <netdev@vger.kernel.org>; Tue, 26 Feb 2013 14:57:26 +0000 (UTC)
Received: from CO1EHSMHS024.bigfish.com (unknown [10.243.78.201])	by
 mail166-co1.bigfish.com (Postfix) with ESMTP id 5300F540230	for
 <netdev@vger.kernel.org>; Tue, 26 Feb 2013 14:57:24 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I noticed that the return value of __netif_receive_skb is initialized to NET_RX_DROP.

If the bridging code handles the packet and successfully returns RX_HANDLER_CONSUMED, __netif_receive_skb returns the default value, NET_RX_DROP. I don't think it is fair to consider the packet dropped, since it is received successfully.

I thought the return value of __netif_receive_skb was used by Ethernet NIC drivers for updating their RX_DROP and RX_OX counters, but I studied the source code of various drivers and they seem to ignore whatever the return value. It seems strange. Then shouldn't the function header look like      " void netif_receive_skb(... "  ?

Thank you,
Cristian Bercaru
