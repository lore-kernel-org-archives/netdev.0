From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 1/2] smc91x: always use 8-bit access if necessary
Date: Thu, 25 Aug 2016 23:33:08 +0100
Message-ID: <20160825223308.GJ1041@n2100.armlinux.org.uk>
References: <20160825144633.1850889-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
 Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Robert Jarzmik <robert.jarzmik@free.fr>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20160825144633.1850889-1-arnd@arndb.de>
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

On Thu, Aug 25, 2016 at 04:46:20PM +0200, Arnd Bergmann wrote:
> +#define SMC_out16(x, ioaddr, reg)					     \
> +do {									     \
> +	if (SMC_CAN_USE_8BIT && !SMC_16BIT(lp)) {			     \
> +		unsigned int __val16 = (x);				     \
> +		SMC_outb(__val16, ioaddr, reg );			     \
> +		SMC_outb(__val16 >> 8, ioaddr, reg + (1 << SMC_IO_SHIFT));   \
> +	} else {							     \
> +		SMC_outw(x, ioaddr, reg);				     \
> +	}								     \

This is insufficient.  If you look at how SMC_REG works, you'll notice
that it has side effects which can disrupt other accesses (it reads
the bank register if debugging is enabled.)

In any case, please wait for my tested patch for this.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
