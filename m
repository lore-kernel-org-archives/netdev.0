From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 45/62] net: irq: Remove IRQF_DISABLED
Date: Wed, 7 Sep 2011 20:03:14 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1109072000290.2723@ionos>
References: <1315383059-3673-46-git-send-email-yong.zhang0@gmail.com>
	<20110907.131325.897937687962213943.davem@davemloft.net>
	<alpine.LFD.2.02.1109071932100.2723@ionos>
	<20110907.135234.17759197083710999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: perex@perex.cz, dhowells@redhat.com, prakity@marvell.com,
	netdev@vger.kernel.org, chunkeey@googlemail.com,
	sonic.zhang@analog.com, klaus.kudielka@ieee.org,
	t.sailer@alumni.ethz.ch, khilman@ti.com, eric.dumazet@gmail.com,
	jhovold@gmail.com, cyril@ti.com, rmk+kernel@arm.linux.org.uk,
	mingo@elte.hu, jpr@f6fbb.org, adobriyan@gmail.com,
	jreuter@yaina.de, cbe-oss-dev@lists.ozlabs.org,
	martinez.javier@gmail.com, samuel@sortiz.org, vapier@gentoo.org,
	grundler@parisc-linux.org, yong.zhang0@gmail.com,
	tklauser@distanz.ch, lucas.demarchi@profusion.mobi,
	u.kleine-koenig@pengutronix.de, olof@lixom.net,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-hams@vger.kernel.org, leitao@linux.vnet.ibm.com,
	blogic@openwrt.org, shawn.guo@linaro.org, nico@fluxnic.net,
	geoff@infradead.org, jkosina@suse.cz,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ralf@linux-mips.org, ralph.
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20110907.135234.17759197083710999.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Sep 2011, David Miller wrote:

> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Wed, 7 Sep 2011 19:32:39 +0200 (CEST)
> 
> > On Wed, 7 Sep 2011, David Miller wrote:
> > 
> >> From: Yong Zhang <yong.zhang0@gmail.com>
> >> Date: Wed,  7 Sep 2011 16:10:42 +0800
> >> 
> >> > This flag is a NOOP and can be removed now.
> >> > 
> >> > Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
> >> 
> >> I have the same concerns here as I had for the sparc case.
> >> 
> >> Some of these drivers might be using IRQF_DISABLED to make sure the
> >> IRQ cannot be delivered until it is explicitly enabled via an
> >> enable_irq() call.
> >> 
> >> How is that being accomodated now?
> > 
> > Again IRQF_DISABLED never ever had that functionality. 
> 
> My bad.
> 
> But what if these interrupts want interrupts disabled during their
> interrupt handler, for other reasons?

We run ALL interrupt handlers with irqs disabled always.
 
> This has the potential to break tons of stuff, especially on the
> really old chips which almost no developers have any more but some
> user might try to use.

It won't. We removed IRQF_DISABLED from kernel/irq/* long ago

Thanks,

	tglx
