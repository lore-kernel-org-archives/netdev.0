From: Nicolas Pitre <nico@fluxnic.net>
Subject: Re: [PATCH v2 1/2] smc91x: always use 8-bit access if necessary
Date: Thu, 25 Aug 2016 13:48:32 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1608251347170.17623@knanqh.ubzr>
References: <20160825144633.1850889-1-arnd@arndb.de>
 <3107598.uul2xx8LJA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>, netdev@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org,
 Robert Jarzmik <robert.jarzmik@free.fr>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <3107598.uul2xx8LJA@wuerfel>
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

On Thu, 25 Aug 2016, Arnd Bergmann wrote:

> As Russell King found out the hard way, a change I did to fix multiplatform
> builds with this driver broke the old Assabet/Neponset platform: It turns
> out that while the driver is runtime configurable in principle, the
> runtime configuration does not cover the specific case of machines that
> can not do any 16-bit I/O on the smc91x registers.
> 
> The driver currently provides helpers to access 16-bit registers for
> architectures that are known at compile-time to only have 8-bit I/O,
> but my patch changed it to a runtime flag that never gets consulted
> most register accesses.
> 
> This introduces new SMC_out16()/SMC_in16 helpers (if anyone can suggest
> a better name, I'm glad to modify this) that behaves like SMC_outw()/SMC_inw()
> most of the time, but uses a pair of 8-bit accesses on platforms that
> have no support for wider register accesses.

Why don't you fold this directly into SMC_outw() instead?


Nicolas
