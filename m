From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.25.3 5/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Wed, 25 Jun 2008 22:46:11 -0700
Message-ID: <20080625224611.49022dba@extreme>
References: <72981EBCFD196144B7C6999B9FC34A9A3EE603B868@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jie Yang <Jie.Yang@Atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50318 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbYFZFqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 01:46:19 -0400
In-Reply-To: <72981EBCFD196144B7C6999B9FC34A9A3EE603B868@SHEXMB-01.global.atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jun 2008 13:38:17 +0800
Jie Yang <Jie.Yang@Atheros.com> wrote:

> From: Jie Yang <jie.yang@atheros.com>
> 
> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114
> 
> Signed-off-by: Jie Yang <jie.yang @atheros.com>

> +#define AT_MII_LOCK(_adapter)                          \
> +       do {                                            \
> +               spin_lock(&(_adapter)->mdio_lock);      \
> +       } while (0)
> +
> +#define AT_MII_UNLOCK(_adapter)                                \
> +       do {                                            \
> +               spin_unlock(&(_adapter)->mdio_lock);    \
> +       } while (0)
> +
> +#define AT_MII_LOCK_IRQSAVE(_adapter, _flags)                          \
> +       do {                                                            \
> +               spin_lock_irqsave(&(_adapter)->mdio_lock, (_flags));    \
> +       } while (0)
> +
> +#define AT_MII_UNLOCK_IRQRESTORE(_adapter, _flags)                      \
> +       do {                                                             \
> +               spin_unlock_irqrestore(&(_adapter)->mdio_lock, (_flags));\
> +       } while (0)
> +

Please don't obfuscate (ie wrap) locking primitives. It makes it harder
for humans to evaluate the locking.
