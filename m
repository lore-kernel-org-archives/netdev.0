From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 17:42:18 +0200
Message-ID: <18167.56026.110424.687062@robur.slu.se>
References: <46F6905C.6030309@opengridcomputing.com>
	<20070923172803.GA11997@2ka.mipt.ru>
	<46F6A887.1030301@opengridcomputing.com>
	<1190571527.4256.78.camel@localhost>
	<46F75968.4010307@candelatech.com>
	<46F7C185.1030202@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, hadi@cyberus.ca,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:60251 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938AbXIXPmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 11:42:22 -0400
In-Reply-To: <46F7C185.1030202@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Steve Wise writes:
 > I think pktgen should be cloning the skbs using skb_clone().  Then it 
 > will work for all devices, eh?

 pktgen assumes for "fastpath" sending exclusive ownership of
 the skb. And does a skb_get to avoid final skb destruction so 
 the same skb can be sent over and over. The idea is to avoid 
 memory allocation and keep things in cache to give very high
 packet rates with identical packets.
   I
 But if you need to alter the packet then the skb_get trick can't 
 be done. And you have to turn off "fastpath" with clone_skb 

 > Perf-wise, you could clone the skbs up front, then deliver them to the 
 > nic in a tight loop.  This would mitigate the added overhead introduced 
 > by calling skb_clone() in the loop doing transmits...

 Sure it's can be done. It could replay sequences etc but it will not
 beat the skb_get trick in sending identical packets. It has been
 proposed before but I've avoided such efforts to keep things relatively 
 small and simple. Really pktgen should be reworked to have s small 
 skim in kernel and move the rest of the stuff to userland.

 Cheers.
					--ro
