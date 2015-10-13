From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net/fsl_pq_mdio: fix computed address for the
 TBI register
Date: Tue, 13 Oct 2015 04:30:22 -0700 (PDT)
Message-ID: <20151013.043022.342257265586096881.davem@davemloft.net>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
	<1444634321-14902-1-git-send-email-gerlando.falauto@keymile.com>
	<1444634321-14902-2-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timur@tabi.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	ogabbay@advaoptical.com, bigeasy@linutronix.de,
	galak@kernel.crashing.org
To: gerlando.falauto@keymile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444634321-14902-2-git-send-email-gerlando.falauto@keymile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerlando Falauto <gerlando.falauto@keymile.com>
Date: Mon, 12 Oct 2015 09:18:41 +0200

> commit afae5ad78b342f401c28b0bb1adb3cd494cb125a
>   "net/fsl_pq_mdio: streamline probing of MDIO nodes"
> 
> added support for different types of MDIO devices:
> 1) Gianfar MDIO nodes that only map the MII registers
> 2) Gianfar MDIO nodes that map the full MDIO register set
> 3) eTSEC2 MDIO nodes (which map the full MDIO register set)
> 4) QE MDIO nodes (which map only the MII registers)
> 
> However, the implementation for types 1 and 4 would mistakenly assume
> a mapping of the full MDIO register set, thereby computing the address
> for the TBI register starting from the containing structure.
> The TBI register would therefore be accessed at a wrong (much bigger)
> address, not giving the expected result at all.
> This patch restores the correct behavior we had prior to the above one.
> 
> The consequences of this bug are apparent when trying to access a PHY
> with the same address as the value contained in the initial value of
> the TBI register (normally 0); in that case you'll get answers from the
> internal TBI device (even though MDIO/MDC pins are actually *also*
> toggling on the physical bus!).
> Beware that you also need to add a fake tbi node to your device tree
> with an unused address.
> 
> Notice how this fix is related to commit
> 220669495bf8b68130a8218607147c7b74c28d2b
>   "powerpc: Add TBI PHY node to first MDIO bus"
> 
> which fixed the behavior in kernel 3.3, which was later broken by the
> above commit on kernel 3.7.
> 
> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>

Applied.
