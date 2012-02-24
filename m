From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] davinci_emac: Do not free all rx dma descriptors
	during init
Date: Fri, 24 Feb 2012 03:25:31 -0500
Message-ID: <20120224.032531.607179170339382701.davem@davemloft.net>
References: <1329995657-7051-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1329995657-7051-1-git-send-email-christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Date: Thu, 23 Feb 2012 12:14:17 +0100

> This patch fixes a regression that was introduced by
> 
> commit 0a5f38467765ee15478db90d81e40c269c8dda20
> davinci_emac: Add Carrier Link OK check in Davinci RX Handler
> 
> Said commit adds a check whether the carrier link is ok. If the link is
> not ok, the skb is freed and no new dma descriptor added to the rx dma
> channel. This causes trouble during initialization when the carrier
> status has not yet been updated. If a lot of packets are received while
> netif_carrier_ok returns false, all dma descriptors are freed and the
> rx dma transfer is stopped.
> 
> The bug occurs when the board is connected to a network with lots of
> traffic and the ifconfig down/up is done, e.g., when reconfiguring
> the interface with DHCP.
> 
> The bug can be reproduced by flood pinging the davinci board while doing
> ifconfig eth0 down
> ifconfig eth0 up
> on the board.
> 
> After that, the rx path stops working and the overrun value reported
> by ifconfig is counting up.
> 
> This patch reverts commit 0a5f38467765ee15478db90d81e40c269c8dda20
> and instead issues warnings only if cpdma_chan_submit returns -ENOMEM.
> 
> Signed-off-by: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>

Applied to 'net', thanks.
