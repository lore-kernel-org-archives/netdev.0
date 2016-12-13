From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] ARM: add cmpxchg64 helper for ARMv7-M
Date: Tue, 13 Dec 2016 16:58:12 +0000
Message-ID: <20161213165811.GZ14217@n2100.armlinux.org.uk>
References: <20161210103646.1407256-1-arnd@arndb.de>
 <20161210123234.GA5468@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, coreteam@netfilter.org,
 netfilter-devel@vger.kernel.org,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20161210123234.GA5468@salvia>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 10, 2016 at 01:32:34PM +0100, Pablo Neira Ayuso wrote:
> Hi Arnd,
> 
> On Sat, Dec 10, 2016 at 11:36:34AM +0100, Arnd Bergmann wrote:
> > A change to the netfilter code in net-next introduced the first caller of
> > cmpxchg64 that can get built on ARMv7-M, leading to an error from the
> > assembler that points out the lack of 64-bit atomics on this architecture:
> > 
> > /tmp/ccMe7djj.s: Assembler messages:
> > /tmp/ccMe7djj.s:367: Error: selected processor does not support `ldrexd r0,r1,[lr]' in Thumb mode
> > /tmp/ccMe7djj.s:371: Error: selected processor does not support `strexd ip,r2,r3,[lr]' in Thumb mode
> > /tmp/ccMe7djj.s:389: Error: selected processor does not support `ldrexd r8,r9,[r7]' in Thumb mode
> > /tmp/ccMe7djj.s:393: Error: selected processor does not support `strexd lr,r0,r1,[r7]' in Thumb mode
> > scripts/Makefile.build:299: recipe for target 'net/netfilter/nft_counter.o' failed
> > 
> > This makes ARMv7-M use the same emulation from asm-generic/cmpxchg-local.h
> > that we use on architectures earlier than ARMv6K, to fix the build. The
> > 32-bit atomics are available on ARMv7-M and we keep using them there.
> > This ARM specific change is probably something we should do regardless
> > of the netfilter code.
> > 
> > However, looking at the new nft_counter_reset() function in nft_counter.c,
> > this looks incorrect to me not just on ARMv7-M but also on other
> > architectures, with at least the following possible race:
> 
> Right, Eric Dumazet already spotted this problem. I'm preparing a
> patch that doesn't require cmpxchg64(). Will keep you on Cc. Thanks.

Please keep me on the Cc as well so I know what's happening, thanks.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
