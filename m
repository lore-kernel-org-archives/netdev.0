From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 05:08:34 +0400
Message-ID: <20080922010834.GB3059@2ka.mipt.ru>
References: <1221387956.9204.7.camel@fry> <20080921.010458.216237442.davem@davemloft.net> <20080922002153.GC1878@2ka.mipt.ru> <20080921.174450.20349529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:56899 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831AbYIVBJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 21:09:27 -0400
Content-Disposition: inline
In-Reply-To: <20080921.174450.20349529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 05:44:50PM -0700, David Miller (davem@davemloft.net) wrote:
> > > Applications which work over datagram protocols must perform their own
> > > segmentation.  It is not like doing a send over a stream protocol like
> > > TCP, where you can use whatever length you want for send calls and
> > > segmentation is done for the application.
> > 
> > But isn't the whole idea of the sendfile() is to send a file no matter
> > what underlying media is?
> 
> It's a way to fabricate a send() directly from the page cache.

And to send exactly required number of bytes (or size of the cache)?
To send a single page (combined to several other pages) we have simple
->sendpage() callback, which should not return error when it is asked to
send a data and it can do it by actually submitting two packets without
special tcp-like processing of the segments.

> > That's maybe because udp_sendpage() does not support sending pending
> > data if new packet is too big to attach?
> 
> I don't think so.
> 
> It's simply enforcing the wsize/rsize that's configured for the mount.
> And this is exactly deciding what the UDP segment size should be.

And what if it is just a result of the knowledge on how udp_sendpage()
behaves, so code adjusts packet sizes in advance?

-- 
	Evgeniy Polyakov
