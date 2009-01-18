From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: sendfile(), SO_LINGER, RST etc summary, please check
Date: Sun, 18 Jan 2009 13:33:39 +0300
Message-ID: <20090118103339.GA14823@ioremap.net>
References: <20090117220229.GA30661@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <bert.hubert@netherlabs.nl>,
	Bill Fink <billfink@mindspring.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	ilpo.jarvinen@helsinki.fi, h.willstrand@gmail.com,
	netdev@vger
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:52311 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755293AbZARKdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2009 05:33:39 -0500
Content-Disposition: inline
In-Reply-To: <20090117220229.GA30661@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bert.

On Sat, Jan 17, 2009 at 11:02:29PM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> As promised, I've written a summary based on all your fine answers with
> regards to my questions on why a close() delivered an immediate RST, even
> though I had SO_LINGER enabled.
> 
> The most up to date version can be found on
> http://ds9a.nl/the-ultimate-so_linger-page-or-why-is-my-tcp-not-reliable.txt
> 
> And I've also included it here. I hope you find the time to see if
> everything I wrote is correct. Suggestions for additional material are also
> very welcome!

Looks very good, thanks for storing the docs!

> But it does not wait until all the data has been acknowledged.
> 
> I don't yet known how the slice() function call behaves in this situation.

splice() from the fd to socket behaves exactly the same, since right now
sendfile() is implemented as a splice(). Other directions are not
affected by this behaviour (like socket-pipe-socket). Userspace memory
to socket (aka vmsplice()) iirc behaves exactly like splice(), i.e. it
is not allowed to write to the area being transmitted until explicit ack
was received.

-- 
	Evgeniy Polyakov
