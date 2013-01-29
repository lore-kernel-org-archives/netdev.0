From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/5] net: mvmdio: unmap base register address at driver
 removal
Date: Tue, 29 Jan 2013 16:32:42 +0100
Message-ID: <20130129163242.1df2caf5@skate>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org>
	<1359473048-26551-2-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1359473048-26551-2-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Florian Fainelli,

On Tue, 29 Jan 2013 16:24:04 +0100, Florian Fainelli wrote:
> Fix the driver remove callback to unmap the base register address and
> not leak this mapping after the driver has been removed.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

What about using devm_request_and_ioremap() instead, in order to get
automatic unmap on error and in the ->remove() path?

But maybe it won't work because this memory range is claimed both by
the MDIO driver and the Ethernet driver itself. In that case, you could
use devm_ioremap().

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
