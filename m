From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Tue, 15 Aug 2006 22:52:37 -0400
Message-ID: <20060815225237.03df7874.billfink@mindspring.com>
References: <20060814110359.GA27704@2ka.mipt.ru>
	<1155558313.5696.167.camel@twins>
	<20060814123530.GA5019@2ka.mipt.ru>
	<1155639302.5696.210.camel@twins>
	<20060815112617.GB21736@2ka.mipt.ru>
	<1155643405.5696.236.camel@twins>
	<20060815123438.GA29896@2ka.mipt.ru>
	<1155649768.5696.262.camel@twins>
	<20060815141501.GA10998@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:41398 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1750848AbWHPCwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 22:52:47 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060815141501.GA10998@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006, Evgeniy Polyakov wrote:

> On Tue, Aug 15, 2006 at 03:49:28PM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> 
> > It could if you can provide adequate detection of memory pressure and
> > fallback to a degraded mode within the same allocator/stack and can
> > guarantee limited service to critical parts.
> 
> It is not needed, since network allocations are separated from main
> system ones.
> I think I need to show an example here.
> 
> Let's main system works only with TCP for simplicity.
> Let's maximum allowed memory is limited by 1mb (it is 768k on machine
> with 1gb of ram).

The maximum amount of memory available for TCP on a system with 1 GB
of memory is 768 MB (not 768 KB).

[bill@chance4 ~]$ cat /proc/meminfo
MemTotal:      1034924 kB
...

[bill@chance4 ~]$ cat /proc/sys/net/ipv4/tcp_mem
98304   131072  196608

Since tcp_mem is in pages (4K in this case), maximum TCP memory
is 196608*4K or 768 MB.

Or am I missing something obvious.

						-Bill
