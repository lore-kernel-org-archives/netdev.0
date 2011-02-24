From: David Miller <davem@davemloft.net>
Subject: Re: via-rhine -- VT6105M and checksum offloading
Date: Thu, 24 Feb 2011 12:23:54 -0800 (PST)
Message-ID: <20110224.122354.193728354.davem@davemloft.net>
References: <20110224185805.GI30393@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755532Ab1BXUXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 15:23:18 -0500
In-Reply-To: <20110224185805.GI30393@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Thu, 24 Feb 2011 13:58:05 -0500

> I've recently noticed that one of the embedded systems I'm using (the 
> PCEngines ALIXes) is becoming CPU bound under heavy network traffic.  
> Upon investigation, it looks like the VT6105M isn't actually using the 
> hardware checksum offloading support of the hardware.  Are there any 
> known reasons why this isn't enabled (hardware bugs?)?  I'll test enabling 
> it in the driver, but I figured it would be worth asking if this path 
> has been explored already.  Cheers,

As far as I can tell it was never attempted.  So it should work.

If you do that, while you're here, you can make rhine_rx() take
a "napi" arg and make this driver use netif_gso_receive() too.
Don't forget to set NETIF_F_GRO or similar in netdev->flags during
probe, and also hookup the necessary ethtool hooks.
