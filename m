From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 05:31:48 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015E3F06@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375330601-3609-1-git-send-email-xobs@kosagi.com>
 <1375330601-3609-2-git-send-email-xobs@kosagi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Steven Rostedt <rostedt@goodmis.org>
To: Sean Cross <xobs@kosagi.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0189.outbound.messaging.microsoft.com ([213.199.154.189]:21832
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751246Ab3HAFby convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 01:31:54 -0400
In-Reply-To: <1375330601-3609-2-git-send-email-xobs@kosagi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 12:17 PM, Sean Cross wrote:

> +/* Write/read to/from extended registers */
> +#define MII_KSZPHY_EXTREG                       0x0b
> +#define KSZPHY_EXTREG_WRITE                     0x8000
> +
> +#define MII_KSZPHY_EXTREG_WRITE                 0x0c
> +#define MII_KSZPHY_EXTREG_READ                  0x0d
> +
> +/* Write/read to/from extended registers */
> +#define MII_KSZPHY_EXTREG                       0x0b
> +#define KSZPHY_EXTREG_WRITE                     0x8000
> +
> +#define MII_KSZPHY_EXTREG_WRITE                 0x0c
> +#define MII_KSZPHY_EXTREG_READ                  0x0d
> +

Pls don't re-define the registers address and field.

> +		if (!of_property_read_u32(of_node,
> +					  "micrel,clk-control-pad-skew",
> +					  &val))
> +			kszphy_extended_write(phydev,
> +					      MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
> +					      val);

When re-set rx/tx clock delay, rx/tx control delay, it is better to do dummy read the extended MII_KSZPHY_CLK_CONTROL_PAD_SKEW register one time.

Thanks,
Andy
