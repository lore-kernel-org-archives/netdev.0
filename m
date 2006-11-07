From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take21 0/4] kevent: Generic event handling mechanism.
Date: Tue, 7 Nov 2006 15:29:26 +0300
Message-ID: <20061107122926.GA15515@2ka.mipt.ru>
References: <11619654014077@2ka.mipt.ru> <45506D51.30604@garzik.org> <20061107115111.GA13028@2ka.mipt.ru> <4550793F.4070102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37862 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1752259AbWKGMdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 07:33:42 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4550793F.4070102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 07:17:03AM -0500, Jeff Garzik (jeff@garzik.org) wrote:
> Evgeniy Polyakov wrote:
> >Well, kevent network and FS AIO are suspended for now (although first
> 
> Why?
> 
> IMO, getting async event submission right is important.  It should be 
> designed in parallel with async event reception.

It was not only designed but also implemented, but...

FS AIO was confirmed to have correct design, but there were minor (from
my point of view) layering design problems 
(I was almost suggested to make myself a lobotomy after I put
get_block() callback into address_space_operations, there were also some
code duplication of mpage_readpages() in async way in
kevent/kevent_aio.c - I made it to separate kevent as much as possible,
both changes can live in fs/ with appropriate callback export).

Network AIO I postponed for a while, since looking how hard core changed
are processed, it looks like a better decision...
Using Ulrich's DMA allocation API (if it would exist not only as
proposal) it would be possible to speed up NAIO yet a bit too.

Kevent based FS AIO patch can be found for example here (it contains
full kevent subsystem with network aio and fs aio):
http://tservice.net.ru/~s0mbre/archive/kevent/kevent_full.diff.3

Network aio homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=naio

> 	Jeff
> 

-- 
	Evgeniy Polyakov
