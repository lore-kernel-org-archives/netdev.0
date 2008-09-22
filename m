From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 17:44:50 -0700 (PDT)
Message-ID: <20080921.174450.20349529.davem@davemloft.net>
References: <1221387956.9204.7.camel@fry>
	<20080921.010458.216237442.davem@davemloft.net>
	<20080922002153.GC1878@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751971AbYIVApE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 20:45:04 -0400
In-Reply-To: <20080922002153.GC1878@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 22 Sep 2008 04:21:57 +0400

> On Sun, Sep 21, 2008 at 01:04:58AM -0700, David Miller (davem@davemloft.net) wrote:
> > Applications which work over datagram protocols must perform their own
> > segmentation.  It is not like doing a send over a stream protocol like
> > TCP, where you can use whatever length you want for send calls and
> > segmentation is done for the application.
> 
> But isn't the whole idea of the sendfile() is to send a file no matter
> what underlying media is?

It's a way to fabricate a send() directly from the page cache.

> That's maybe because udp_sendpage() does not support sending pending
> data if new packet is too big to attach?

I don't think so.

It's simply enforcing the wsize/rsize that's configured for the mount.
And this is exactly deciding what the UDP segment size should be.
