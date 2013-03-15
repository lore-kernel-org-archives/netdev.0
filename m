From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: netjet requires VIRT_TO_BUS
Date: Fri, 15 Mar 2013 08:33:44 -0400 (EDT)
Message-ID: <20130315.083344.2224038988420448687.davem@davemloft.net>
References: <201303151015.00746.arnd@arndb.de>
	<20130315.081659.636423702994054939.davem@davemloft.net>
	<201303151229.52997.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org, dhowells@redhat.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201303151229.52997.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 15 Mar 2013 12:29:52 +0000

> On Friday 15 March 2013, David Miller wrote:
>> I do not want to see us add such a Kconfig dependency knob.
>> 
>> Then the real tendency will exist to make new drivers little-endian
>> only, refuse to fix endian-broken old drivers, etc.
>> 
>> Which means that allmodconfig on my architecture will have build
>> coverage on less code, which is really the only thing that matters
>> for me.  I want all drivers that could be effected by my changes
>> to be compile testable on as many platforms as possible.
> 
> There are two separate issues here. The first one that David Howells
> brought up was ill-defined __BIG_ENDIAN/__LITTLE_ENDIAN macros.
> Using CONFIG_CPU_IS_BIG_ENDIAN/CONFIG_CPU_IS_LITTLE_ENDIAN in the code
> is what Linus suggested as a replacement, although I see little
> incentive to do mass conversion there, it would be mainly for new
> code.
> 
> The other issue is the Kconfig logic where Geert would replace
> all the instances of "depends on BROKEN || !(SPARC || PPC || PARISC ||
> M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA &&
> !CPU_LITTLE_ENDIAN))" with something that actually reflects what
> we mean. I think it would be a nice cleanup, but I can also understand
> your hesitation there.
> 
> Do you object to both uses of that symbol, or just to using it in order
> to disable drivers in Kconfig? I don't care too much right now, since
> nothing is actually broken at the moment, I would just like to get
> the VIRT_TO_BUS patch merged so people can also build allmodconfig
> on my architecture ;-)

The first usage seems reason, but the temtation is going to be quite
strong to misuse to block out drivers when there is "no value" in
spending time necessary to simply make them endian clean instead.
