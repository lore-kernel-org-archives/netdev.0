From: Chris Larson <clarson@mvista.com>
Subject: MV643xx Ethernet Driver Issue on a Motorola PrPMC-275 board.
Date: Tue, 29 Jul 2008 10:49:09 -0700
Message-ID: <488F5815.9020402@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:33343 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbYG2Rsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 13:48:41 -0400
Received: from [10.50.1.118] (unknown [10.50.1.118])
	by hermes.mvista.com (Postfix) with ESMTP id 21905182B0
	for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 10:48:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I was wondering if anyone had any advice on an issue a customer of ours 
is running into.  When they run a series of bandwidth tests, slowly 
increasing the bandwidth & # of tcp connections to roughly 30Mbit at 
4000 connections, their machine panics.  An address passed to 
dma_unmap_single is beyond lowmem, as though it was corrupted in some 
fashion.  The address is the data pointer in the ethernet dma 
descriptors, it pulls a descriptor out of the ring in the packet receipt 
functions and at that point the address is wrong.  Nowhere in the driver 
is a descriptor set up with that address, yet the datasheet on the 
mv643xx doesn't seem to indicate that the dma engine ever writes to the 
descriptors themselves, only to the data they point to (as you'd 
expect).  Does anyone have any ideas on this?  I'm afraid that I'm a bit 
out of my depth on this issue.  The architecture is ppc.

Thanks.
-- 
Chris Larson
clarson at kergoth dot com
clarson at mvista dot com
Software Engineer
MontaVista Software, Inc.
