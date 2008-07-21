From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Mon, 21 Jul 2008 22:23:34 +0200
Message-ID: <19f34abd0807211323o11f38bf6ja756d196da1d7a1f@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
	 <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu>
	 <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com>
	 <20080721100627.GA5953@2ka.mipt.ru> <20080721105051.GA5830@elte.hu>
	 <19f34abd0807210403n1bca348fn83773b55a08b7993@mail.gmail.com>
	 <4884B724.40401@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, davem@davemloft.net
To: "Christoph Lameter" <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:65384 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbYGUUXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:23:34 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1778438wfd.4
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 13:23:34 -0700 (PDT)
In-Reply-To: <4884B724.40401@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 6:19 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
>> (There was recently an odd case of kzalloc() succeeding even though it
>> was called before the slab caches were initialized -- and it only
>> generated a warning about irqs-on happening too early. I just mean to
>> say that it _can_ happen. On another machine, it crashed
>> spectacularly. I guess you're not enabling the netconsole before slab
>> allocator is up?)
>
> Kzalloc for objects > 4k will succeed even during early boot since we will
> directly call into the page allocator.

It wasn't just that; it got into __slab_alloc() and out again. See the
backtrace at http://lkml.org/lkml/2008/7/19/23

It's scary, I know. It's a good thing we have irqtrace :-)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
