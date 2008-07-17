From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 01:35:34 +0200
Message-ID: <19f34abd0807171635k4d46869oef830741178e9193@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:53419 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbYGQXfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:35:36 -0400
Received: by yw-out-2324.google.com with SMTP id 9so13941ywe.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:35:35 -0700 (PDT)
In-Reply-To: <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 1:15 AM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
>>
>> A regression to v2.6.26:
>>
>> I started getting this skb-head corruption message today, on a T60
>> laptop with e1000:
>>
>> PM: Removing info for No Bus:vcs11
>> device: 'vcs11': device_create_release
>> =============================================================================
>> BUG skbuff_head_cache: Poison overwritten
>> -----------------------------------------------------------------------------
>>
>> INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
>
> 1. Notice the range. It's just a single byte.
> 2. Notice the value. It's just a ++.
>
> Probably a stray increment of a uint8_t somewhere on a freed object?
>
> The offset from the beginning of the object is 0xf658ae9c - 0xf658ae00 = 0x9c.
>
> How big is a struct sk_buff? Hm.. it is in fact quite big. Now what
> member has offset 0x9c? Seems to depend on your config. Is there any
> way you can figure it out, Ingo? I'll try it with your config too.

With your config:

(gdb) p ((struct sk_buff *) 0)->truesize
Cannot access memory at address 0x9c

Now just audit users of ->truesize... There are quite a few.

Which one would only += 1?


Vegard

PS: I might be on the completely wrong track. So far I only have bad
experiences with this sk_buff...

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
