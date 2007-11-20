From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 14:27:07 -0800 (PST)
Message-ID: <20071120.142707.32641887.davem@davemloft.net>
References: <471E0F3B.2020703@myri.com>
	<20071119.210919.177660672.davem@davemloft.net>
	<47433972.10903@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, netdev@vger.kernel.org, ossthema@de.ibm.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48045
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755890AbXKTW1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 17:27:12 -0500
In-Reply-To: <47433972.10903@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 20 Nov 2007 11:45:54 -0800

> Sounds like one might as well go ahead and implement HP-UX/Solaris-like 
> ACK sending avoidance at the receiver and not bother with LRO-ACK on the 
> sender.
> 
> In some experiements a while back I thought I saw that LRO on the 
> receiver was causing him to send fewer ACKs already?  IIRC that was with 
> a Myricom card, perhaps I was fooled by it's own ACK LRO it was doing.

Linux used to do aggressive ACK deferral, especially when the ucopy
code paths triggered.

I removed that code because I had several scenerios where it hurt more
than it helped performance, and the IETF has explicitly stated in
several documents the (proven) perils of such stretch ACKs.
