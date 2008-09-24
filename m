From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Wed, 24 Sep 2008 00:53:35 -0400
Message-ID: <20080924005335.0117c536.billfink@mindspring.com>
References: <20080922070425.GA14572@2ka.mipt.ru>
	<E1Khzut-0006lv-Co@gondolin.me.apana.org.au>
	<20080923062709.GA7886@2ka.mipt.ru>
	<20080923070133.GB26836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, davem@davemloft.net,
	johaahn@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:37207 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbYIXEyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 00:54:04 -0400
In-Reply-To: <20080923070133.GB26836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008, Herbert Xu wrote:

> On Tue, Sep 23, 2008 at 10:27:10AM +0400, Evgeniy Polyakov wrote:
> > On Tue, Sep 23, 2008 at 12:54:27PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > I think this dicussion is moot since the only time you want to use
> > > sendfile is for bulk transfers and these days anybody designing new
> > > applications that does bulk transfers over UDP should be taken out
> > > and shot.
> > 
> > One can protect himself pointing how slow may be memory bus in some
> > hardware setup, which completely does not allow to perform any copy.
> 
> Yes but bulk transfers over UDP is a bad idea regardless of how
> slow your bus is :)
> 
> So what application needs this?

It seems it might be useful for a video server.  The one thing that
seems to be missing from the sendfile() semantics is a message size
to be used for splitting the file into UDP datagrams, but this could
be provided by a separate ioctl(), and could default to the largest
message size that would fit in the MTU.

						-Bill
