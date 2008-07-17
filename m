From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 01:15:47 +0200
Message-ID: <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761180AbYGQXQP@vger.kernel.org>
In-Reply-To: <20080717214222.GA29449@elte.hu>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> A regression to v2.6.26:
>
> I started getting this skb-head corruption message today, on a T60
> laptop with e1000:
>
> PM: Removing info for No Bus:vcs11
> device: 'vcs11': device_create_release
> =============================================================================
> BUG skbuff_head_cache: Poison overwritten
> -----------------------------------------------------------------------------
>
> INFO: 0xf658ae9c-0xf658ae9c. First byte 0x6a instead of 0x6b

1. Notice the range. It's just a single byte.
2. Notice the value. It's just a ++.

Probably a stray increment of a uint8_t somewhere on a freed object?

The offset from the beginning of the object is 0xf658ae9c - 0xf658ae00 = 0x9c.

How big is a struct sk_buff? Hm.. it is in fact quite big. Now what
member has offset 0x9c? Seems to depend on your config. Is there any
way you can figure it out, Ingo? I'll try it with your config too.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
