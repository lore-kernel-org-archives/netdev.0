From: Michael Riesch <michael@riesch.at>
Subject: usbnet with NAPI
Date: Fri, 15 Apr 2011 15:05:35 +0200
Message-ID: <20110415150535.15885rkpiuobevks@webmail.df.eu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.29]:44571 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579Ab1DONFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 09:05:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Habidere,

it looks like the usbnet (on which asix.c bases -> I am still working  
on the driver for the Asix AX88172A[1]) does not use NAPI. It  
processes the data it receives via netif_rx(). The NAPI way would be  
netif_receive_skb in a poll function. Now I would like to check  
whether the incoming packets are PTP status frames. My problem is that  
skb_defer_rx_timestamp (the PTP check is executed there -  
net/core/timestamping.c) is called by netif_receive_skb, but it is not  
called by netif_rx(). So the crude hack would be to call  
skb_defer_rx_timestamp from the netif_rx() in usbnet.

(It caused the whole system to hang after a few minutes of operation,  
so I declared it crude. Haven't found the exact reason for this  
behaviour, though...)

The nicer way would probably be enabling usbnet to use NAPI. Now:

- Is or was there some thinking about usbnet going NAPI? In case of  
the latter, what was the reason that it was not done? (I could not  
find any discussion about that topic)

- Do you see problems doing so? I have read some documentation about  
NAPI [2], the requirements seem to be a DMA ring and the ability to  
turn off interrupts/events that send packets up the stack.

- Who is going to maintain usbnet in the future?

Looking forward to your comments/ideas,
Michael

[1] http://marc.info/?l=linux-netdev&m=130167000017199&w=2
[2] http://www.linuxfoundation.org/collaborate/workgroups/networking/napi


