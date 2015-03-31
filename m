From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: RE: [PATCH v2 8/8] net/macb: unify peripheral version testing
Date: Tue, 31 Mar 2015 14:58:49 +0000
Message-ID: <1563b908-8a90-4eb8-8f4e-6e989c467533@BN1BFFO11FD030.protection.gbl>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
 <1427806926-18887-9-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Boris BREZILLON <boris.brezillon@free-electrons.com>,
 Cyrille Pitchen <cyrille.pitchen@atmel.com>, Michal Simek <michals@xilinx.com>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1427806926-18887-9-git-send-email-nicolas.ferre@atmel.com>
Content-Language: en-US
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



> -----Original Message-----
> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
> Sent: Tuesday, March 31, 2015 6:32 PM
> To: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org; David S.
> Miller
> Cc: linux-kernel@vger.kernel.org; Boris BREZILLON; Cyrille Pitchen; Alexandre
> Belloni; Michal Simek; Punnaiah Choudary Kalluri; Nicolas Ferre
> Subject: [PATCH v2 8/8] net/macb: unify peripheral version testing
> 
> As we need to check peripheral version from the hardware during probe, I
> introduce a little helper to unify these tests. It would prevent to
> de-synchronize the test like previously observed.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
    Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

> ---
> 
> Changes in v2: None
> 
>  drivers/net/ethernet/cadence/macb.c | 7 ++-----
>  drivers/net/ethernet/cadence/macb.h | 5 +++++
>  2 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c
> b/drivers/net/ethernet/cadence/macb.c
> index 4412895cf4a8..448a32309dd0 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2139,10 +2139,9 @@ static void macb_configure_caps(struct macb *bp,
> const struct macb_config *dt_co
>  	if (dt_conf)
>  		bp->caps = dt_conf->caps;
> 
> -	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) >= 0x2)
> +	if (macb_is_gem_hw(bp->regs)) {
>  		bp->caps |= MACB_CAPS_MACB_IS_GEM;
> 
> -	if (macb_is_gem(bp)) {
>  		dcfg = gem_readl(bp, DCFG1);
>  		if (GEM_BFEXT(IRQCOR, dcfg) == 0)
>  			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
> @@ -2159,7 +2158,6 @@ static void macb_probe_queues(void __iomem
> *mem,
>  			      unsigned int *num_queues)
>  {
>  	unsigned int hw_q;
> -	u32 mid;
> 
>  	*queue_mask = 0x1;
>  	*num_queues = 1;
> @@ -2170,8 +2168,7 @@ static void macb_probe_queues(void __iomem
> *mem,
>  	 * we are early in the probe process and don't have the
>  	 * MACB_CAPS_MACB_IS_GEM flag positioned
>  	 */
> -	mid = readl_relaxed(mem + MACB_MID);
> -	if (MACB_BFEXT(IDNUM, mid) < 0x2)
> +	if (!macb_is_gem_hw(mem))
>  		return;
> 
>  	/* bit 0 is never set but queue 0 always exists */
> diff --git a/drivers/net/ethernet/cadence/macb.h
> b/drivers/net/ethernet/cadence/macb.h
> index fd0a22157a88..eb7d76f7bf6a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -833,4 +833,9 @@ static inline bool macb_is_gem(struct macb *bp)
>  	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
>  }
> 
> +static inline bool macb_is_gem_hw(void __iomem *addr)
> +{
> +	return !!(MACB_BFEXT(IDNUM, readl_relaxed(addr + MACB_MID))
> >= 0x2);
> +}
> +
>  #endif /* _MACB_H */
> --
> 2.1.3
