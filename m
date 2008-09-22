From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 08:19:29 +0400
Message-ID: <20080922041929.GA20165@2ka.mipt.ru>
References: <20080922002153.GC1878@2ka.mipt.ru> <20080921.174450.20349529.davem@davemloft.net> <20080922010834.GB3059@2ka.mipt.ru> <20080921.190715.144340989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:46933 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbYIVEUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 00:20:11 -0400
Content-Disposition: inline
In-Reply-To: <20080921.190715.144340989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 07:07:15PM -0700, David Miller (davem@davemloft.net) wrote:
> > And to send exactly required number of bytes (or size of the cache)?
> > To send a single page (combined to several other pages) we have simple
> > ->sendpage() callback, which should not return error when it is asked to
> > send a data and it can do it by actually submitting two packets without
> > special tcp-like processing of the segments.
> 
> You're basically throwing away the difference between datagram and stream
> socket semantics.
> 
> I don't see what else I can explain if you cannot see that this is
> significant.

Hey David, that's getting the wrong direction :)
Do not make decision backed by what you read or decided to think before
that instead of making it clear.

Stream socket means that whatever data we put to it, it will become
completely boundary-free, in that regard, that receiving side will not
be able to get original sending packet sizes (without too much efforts).

Datagram just preservs the boundaries and that's what we have with this
patch. Previously we accumulated a single segment upto predefined size
and sent it when it is complete. Now we are able to sent it when it is
complete and start creating new segment without returning the error.

Like:
previosly: A + A + A + A + send + return
now: A + A + A + A + send + A + A and so on, so effectively nothing
changes except maybe time when segment is being sent: previously it was
on the full size and now it is when new packet does not fit that
predefined size.

-- 
	Evgeniy Polyakov
