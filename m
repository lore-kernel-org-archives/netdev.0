From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 09:03:50 +0200
Message-ID: <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
	 <20080717.190315.186892939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754586AbYGRHEK@vger.kernel.org>
In-Reply-To: <20080717.190315.186892939.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 18, 2008 at 4:03 AM, David Miller <davem@davemloft.net> wrote:
>> On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> >
>> > A regression to v2.6.26:
>> >
>> > I started getting this skb-head corruption message today, on a T60
>> > laptop with e1000:
>> >
>> > PM: Removing info for No Bus:vcs11
>> > device: 'vcs11': device_create_release
>> > =============================================================================
>> > BUG skbuff_head_cache: Poison overwritten
>> > -----------------------------------------------------------------------------
>> >
>> > INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b
>>
>> 1. Notice the range. It's just a single byte.
>> 2. Notice the value. It's just a ++.
>
> It's supposed to be 0x6b, this would be a "--"

You're right! Oops. In my defence, I wrote that at 2 AM last night ;-)

> Also it (more likely IMHO) could be clearing a flag with the value 0x01.

It could be. But like I said in a later e-mail, the thing is likely
sk_buff->truesize. Which is not a flags variable. It _is_ however, a
counter, which is frequently -= and atomic_sub()ed.

That field is also an int, not a byte like I suggested above. This is
fine, though. "--" on an int can of course legitimately update/change
just the lower byte of an int.

But.. it could also be some random corruption coming from elsewhere.
Maybe even bad RAM (it's just a single bit anyway). But that's less
likely.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
