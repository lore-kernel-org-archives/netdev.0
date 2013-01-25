From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC PATCH 4/4] net: mvmdio: add getter and setter for PHY
 addresses
Date: Fri, 25 Jan 2013 11:16:29 -0700
Message-ID: <20130125181629.GA7393@obsidianresearch.com>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org>
 <1359108409-4378-5-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, jason@lakedaemon.net,
 arnd@arndb.de, netdev@vger.kernel.org, gregory.clement@free-electrons.com,
 ian.molton@codethink.co.uk, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1359108409-4378-5-git-send-email-florian@openwrt.org>
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

On Fri, Jan 25, 2013 at 11:06:49AM +0100, Florian Fainelli wrote:
> This patch adds orion_mdio_{set,get}_phy_addr(.., port_number, phy_addr)
> which is a feature available in this MDIO driver to monitor a particular
> PHY address. This brings mvmdio one step closer to what is used in
> mv643x_eth.

This seems really strange.

Are you sure this should be part of the MDIO driver? Based on my docs,
this register is part of the ethernet controller HW, which
autonomously reads from the phy via MDIO.

It seems cleaner to set this register from the ethernet controller
based on the phy it is using and keep the MDIO driver purely for MDIO
bus access.

It is acceptable to overlap the device address ranges, start the
ethernet controller at 72000 and start the MDIO at 72004, the platform
bus code automatically nests them.

Jason
