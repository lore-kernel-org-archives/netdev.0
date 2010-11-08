From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] firewire: net: rate-limit log spam at transmit failure
Date: Mon, 08 Nov 2010 09:12:43 +0100
Message-ID: <4CD7B0FB.8090901@s5r6.in-berlin.de>
References: <tkrat.01ca17fba0508ae0@s5r6.in-berlin.de>	 <tkrat.1b9925fa1d199c23@s5r6.in-berlin.de>	 <tkrat.18b9f67ac78dcbea@s5r6.in-berlin.de>	 <tkrat.276aeae22ec60090@s5r6.in-berlin.de>	 <1289100404.3277.28.camel@maxim-laptop>	 <1289100737.3277.32.camel@maxim-laptop>	 <4CD6957C.5030504@s5r6.in-berlin.de> <1289180517.4318.3.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:50460 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786Ab0KHIMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 03:12:55 -0500
In-Reply-To: <1289180517.4318.3.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky wrote:
> But why the timeout is  never set?

It is set to the default 0.1s per IEEE 1394 in core-card.c::fw_card_initialize.

If card->split_timeout_jiffies or card->split_timeout_cycles /ever/ become
zero, then only due to a memory corrupting bug.

> Also, note that I see here that if I send a TCP stream from one system
> to another then the system that recieves the packets (and sends TCP
> acks), still overflows the queue (error 10, and confirmed by printks).

OK, I'll send a stricter version of "firewire: net: throttle TX queue before
running out of tlabels".
-- 
Stefan Richter
-=====-==-=- =-== -=---
http://arcgraph.de/sr/
