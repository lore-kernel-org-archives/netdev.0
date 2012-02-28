From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Tue, 28 Feb 2012 13:41:01 +0000
Message-ID: <201202281341.01690.arnd@arndb.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E83@saturn3.aculab.com>
 <4F4CD781.2090802@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, baruch@tkos.co.il, ian.campbell@citrix.com,
 netdev@vger.kernel.org, eilong@broadcom.com, Kevin Wells <kevin.wells@nxp.com>,
 Wolfram Sang <w.sang@pengutronix.de>, David Laight <David.Laight@aculab.com>,
 jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4F4CD781.2090802@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 28 February 2012, Roland Stigge wrote:
> Yes, that's why we previously had a cmdline param for it (but removed it
> upon request from the netdev maintainer).
> 
> So if the hardware defaults to 00:00:00:00:00:00, what is the
> "consistent policy we want to enforce in all drivers"?
> 
> A link or hint would be sufficient.

I think the most common strategy for platform drivers these days is

1. use what the hardware provides
2. call of_get_mac_address(dev->of_node, ...)
3. use random_ether_addr

in that order. of_get_mac_address just returns NULL when there
is no device tree or no local-mac-address property, so you can
put it into the driver right away.

	Arnd
