From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smc91x: fix SMC accesses
Date: Sun, 28 Aug 2016 23:46:35 -0400 (EDT)
Message-ID: <20160828.234635.224236136235372450.davem@davemloft.net>
References: <E1bdgXX-0005I4-1N@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, nico@fluxnic.net, netdev@vger.kernel.org, realmz6@gmail.com,
 adi-buildroot-devel@lists.sourceforge.net, haojian.zhuang@gmail.com,
 linux-arm-kernel@lists.infradead.org, robert.jarzmik@free.fr,
 daniel@zonque.org
To: rmk+kernel@armlinux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <E1bdgXX-0005I4-1N@rmk-PC.armlinux.org.uk>
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

From: Russell King <rmk+kernel@armlinux.org.uk>
Date: Sat, 27 Aug 2016 17:33:03 +0100

> Commit b70661c70830 ("net: smc91x: use run-time configuration on all ARM
> machines") broke some ARM platforms through several mistakes.  Firstly,
> the access size must correspond to the following rule:
> 
> (a) at least one of 16-bit or 8-bit access size must be supported
> (b) 32-bit accesses are optional, and may be enabled in addition to
>     the above.
> 
> Secondly, it provides no emulation of 16-bit accesses, instead blindly
> making 16-bit accesses even when the platform specifies that only 8-bit
> is supported.
> 
> Reorganise smc91x.h so we can make use of the existing 16-bit access
> emulation already provided - if 16-bit accesses are supported, use
> 16-bit accesses directly, otherwise if 8-bit accesses are supported,
> use the provided 16-bit access emulation.  If neither, BUG().  This
> exactly reflects the driver behaviour prior to the commit being fixed.
> 
> Since the conversion incorrectly cut down the available access sizes on
> several platforms, we also need to go through every platform and fix up
> the overly-restrictive access size: Arnd assumed that if a platform can
> perform 32-bit, 16-bit and 8-bit accesses, then only a 32-bit access
> size needed to be specified - not so, all available access sizes must
> be specified.
> 
> This likely fixes some performance regressions in doing this: if a
> platform does not support 8-bit accesses, 8-bit accesses have been
> emulated by performing a 16-bit read-modify-write access.
> 
> Tested on the Intel Assabet/Neponset platform, which supports only 8-bit
> accesses, which was broken by the original commit.
> 
> Fixes: b70661c70830 ("net: smc91x: use run-time configuration on all ARM machines")
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Applied and queued up for -stable, thanks Russell.
