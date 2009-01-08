From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Thu, 8 Jan 2009 15:53:00 +0100
Message-ID: <20090108145259.GF18120@elte.hu>
References: <20090106181559.GA29426@1wt.eu> <20090108071651.GA4496@ff.dom.local> <20090108080520.GG30749@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, Ben Mansell <ben@zeus.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:54967 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbZAHOxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 09:53:13 -0500
Content-Disposition: inline
In-Reply-To: <20090108080520.GG30749@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Willy Tarreau <w@1wt.eu> wrote:

> On Thu, Jan 08, 2009 at 07:16:51AM +0000, Jarek Poplawski wrote:
> > On 06-01-2009 19:15, Willy Tarreau wrote:
> > ...
> > > Ah, so you might also have discovered a few annoyances with the API, eg
> > > the fact that splice() returns after the first read in non-blocking mode,
> > > as well as the fact that it never returns zero on close, but -EAGAIN,
> > > which requires an additional recv(MSG_PEEK) to distinguish between a
> > > close and a lack of data. But I leave that for a later discussion, let's
> > > address the corruption issue first.
> > 
> > FYI, this should be just fixed:
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=4f7d54f59bc470f0aaa932f747a95232d7ebf8b1
> > 
> 
> Ah cool, thanks Jarek for notifying us. Indeed, it's the exact same patch
> I had pending here ;-)
> 
> I'll ping Greg for a backport into -stable, as applications relying on 
> this will clearly not work without that fix.
> 
> The other one I had consists in removing "|| !timeo" at the end of the 
> loop, because otherwise splice() returns very small chunks (typically 
> 1448 or 1460 bytes), leading to disastrous performance on high bandwidth 
> links. At 10 Gbps, this means about 800000 calls to splice() per second!

looks interesting - would you mind to submit it?

	Ingo
