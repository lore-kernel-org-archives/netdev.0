From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ARM: add cmpxchg64 helper for ARMv7-M
Date: Sat, 10 Dec 2016 13:32:34 +0100
Message-ID: <20161210123234.GA5468@salvia>
References: <20161210103646.1407256-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <linux@armlinux.org.uk>, netdev@vger.kernel.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161210103646.1407256-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On Sat, Dec 10, 2016 at 11:36:34AM +0100, Arnd Bergmann wrote:
> A change to the netfilter code in net-next introduced the first caller of
> cmpxchg64 that can get built on ARMv7-M, leading to an error from the
> assembler that points out the lack of 64-bit atomics on this architecture:
> 
> /tmp/ccMe7djj.s: Assembler messages:
> /tmp/ccMe7djj.s:367: Error: selected processor does not support `ldrexd r0,r1,[lr]' in Thumb mode
> /tmp/ccMe7djj.s:371: Error: selected processor does not support `strexd ip,r2,r3,[lr]' in Thumb mode
> /tmp/ccMe7djj.s:389: Error: selected processor does not support `ldrexd r8,r9,[r7]' in Thumb mode
> /tmp/ccMe7djj.s:393: Error: selected processor does not support `strexd lr,r0,r1,[r7]' in Thumb mode
> scripts/Makefile.build:299: recipe for target 'net/netfilter/nft_counter.o' failed
> 
> This makes ARMv7-M use the same emulation from asm-generic/cmpxchg-local.h
> that we use on architectures earlier than ARMv6K, to fix the build. The
> 32-bit atomics are available on ARMv7-M and we keep using them there.
> This ARM specific change is probably something we should do regardless
> of the netfilter code.
> 
> However, looking at the new nft_counter_reset() function in nft_counter.c,
> this looks incorrect to me not just on ARMv7-M but also on other
> architectures, with at least the following possible race:

Right, Eric Dumazet already spotted this problem. I'm preparing a
patch that doesn't require cmpxchg64(). Will keep you on Cc. Thanks.
