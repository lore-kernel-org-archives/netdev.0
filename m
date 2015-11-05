From: Guy Harris <guy@alum.mit.edu>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 5 Nov 2015 00:14:51 -0800
Message-ID: <AECBA5BB-2284-4C1E-ADCC-09B730D6EF9A@alum.mit.edu>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:42007 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030399AbbKEIO6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 03:14:58 -0500
In-Reply-To: <20151105.000414.1682124328670738318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 4, 2015, at 9:04 PM, David Miller <davem@davemloft.net> wrote:

> As part of fixing y2038 problems, Arnd is going to have to make a new
> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
> the time values to 64-bit.
> 
> So I want everyone to think about whether there are any other changes
> we might want to make given that we have to make a v4 anyways.
> 
> Particularly, I am rather certain that the buffer management could be
> improved.  Some have complained that v3 is kinda awkward to use and/or
> suboptimal is various ways.

As a core libpcap developer, I will at least state that it works a *lot* better than v1 and v2 did.  Having buffer slots that can hold only one packet is *really* suboptimal for packet capture; having buffer slots that can hold multiple packets works a lot better, as there's less wasted memory.

I'll see whether there are any changes that *would* make libpcap's life better.