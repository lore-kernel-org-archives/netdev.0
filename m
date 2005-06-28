From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] net: add driver for the NIC on Cell Blades
Date: Tue, 28 Jun 2005 15:53:18 +0200
Message-ID: <1119966799.3175.32.camel@laptopd505.fenrus.org>
References: <200506281528.08834.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>, linuxppc64-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200506281528.08834.arnd@arndb.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-06-28 at 15:28 +0200, Arnd Bergmann wrote:
> 
> +static void
> +spider_net_rx_irq_off(struct spider_net_card *card)
> +{
> +       u32 regvalue;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&card->intmask_lock, flags);
> +       regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
> +       regvalue &= ~SPIDER_NET_RXINT;
> +       spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
> +       spin_unlock_irqrestore(&card->intmask_lock, flags);
> +}

I think you have a PCI posting bug here....
