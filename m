From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 19:07:15 -0700 (PDT)
Message-ID: <20080921.190715.144340989.davem@davemloft.net>
References: <20080922002153.GC1878@2ka.mipt.ru>
	<20080921.174450.20349529.davem@davemloft.net>
	<20080922010834.GB3059@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752842AbYIVCH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 22:07:27 -0400
In-Reply-To: <20080922010834.GB3059@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 22 Sep 2008 05:08:34 +0400

> On Sun, Sep 21, 2008 at 05:44:50PM -0700, David Miller (davem@davemloft.net) wrote:
> > > > Applications which work over datagram protocols must perform their own
> > > > segmentation.  It is not like doing a send over a stream protocol like
> > > > TCP, where you can use whatever length you want for send calls and
> > > > segmentation is done for the application.
> > > 
> > > But isn't the whole idea of the sendfile() is to send a file no matter
> > > what underlying media is?
> > 
> > It's a way to fabricate a send() directly from the page cache.
> 
> And to send exactly required number of bytes (or size of the cache)?
> To send a single page (combined to several other pages) we have simple
> ->sendpage() callback, which should not return error when it is asked to
> send a data and it can do it by actually submitting two packets without
> special tcp-like processing of the segments.

You're basically throwing away the difference between datagram and stream
socket semantics.

I don't see what else I can explain if you cannot see that this is
significant.
