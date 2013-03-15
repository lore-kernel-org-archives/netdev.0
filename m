From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 3/4 v2] net: mvmdio: enhance driver to support SMI
	error/done interrupts
Date: Fri, 15 Mar 2013 18:05:03 +0000
Message-ID: <20130315180503.GU4977@n2100.arm.linux.org.uk>
References: <1359473048-26551-1-git-send-email-florian@openwrt.org> <1363284515-9865-1-git-send-email-florian@openwrt.org> <1363284515-9865-4-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363284515-9865-4-git-send-email-florian@openwrt.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 14, 2013 at 07:08:34PM +0100, Florian Fainelli wrote:
> +	if (dev->err_interrupt == NO_IRQ) {
...
> +	init_waitqueue_head(&dev->smi_busy_wait);
> +
> +	dev->err_interrupt = platform_get_irq(pdev, 0);
> +	if (dev->err_interrupt != -ENXIO) {
...
> +	} else
> +		dev->err_interrupt = NO_IRQ;


FYI, NO_IRQ is not supposed to be used anymore (we're supposed to be
removing it).  platform_get_irq() returns negative numbers for failure,
so why not test for < 0 in both the above tests, or maybe <= 0 (as
IRQ0 is also not supposed to be valid.)?
