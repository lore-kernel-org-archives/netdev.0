From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Mon, 21 Jul 2008 13:03:50 +0200
Message-ID: <19f34abd0807210403n1bca348fn83773b55a08b7993@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
	 <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu>
	 <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com>
	 <20080721100627.GA5953@2ka.mipt.ru> <20080721105051.GA5830@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:55674 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755410AbYGULDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:03:51 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1534505wfd.4
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 04:03:50 -0700 (PDT)
In-Reply-To: <20080721105051.GA5830@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 12:50 PM, Ingo Molnar <mingo@elte.hu> wrote:
> the problem is, most of the crashes dont come with any usable dump. This
> is a laptop so netconsole is the only reliable route out - and if
> something in networking crashes chances are that it hoses netconsole
> before it can get anything out.
>
> Another thing is that i'm activating netconsole on this box via a kernel
> boot line and from within a bzImage (to get it activated as early as
> possible) - maybe that's a tad too early for certain initialization
> sequences?
>
> I could try run tests with netconsole deactivated, if you think that's a
> worthwile line of probing this problem. (although that would make me do
> blind tests in essence - having kernel log output is really essential.)

How about posting your custom patches for public review? :-D

(There was recently an odd case of kzalloc() succeeding even though it
was called before the slab caches were initialized -- and it only
generated a warning about irqs-on happening too early. I just mean to
say that it _can_ happen. On another machine, it crashed
spectacularly. I guess you're not enabling the netconsole before slab
allocator is up?)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
