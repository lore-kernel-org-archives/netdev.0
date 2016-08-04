From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v5.1] ucc_fast: Fix to avoid IS_ERR_VALUE abuses and dead code
 on 64bit systems.
Date: Thu, 04 Aug 2016 22:31:30 +0200
Message-ID: <2376517.GXv6XVOdDd@wuerfel>
References: <1470329563-5464-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: qiang.zhao@freescale.com, viresh.kumar@linaro.org, zajec5@gmail.com,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 scottwood@freescale.com, Arvind Yadav <arvind.yadav.cs@gmail.com>,
 akpm@linux-foundation.org, linux@roeck-us.net
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1470329563-5464-1-git-send-email-arvind.yadav.cs@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Thursday, August 4, 2016 10:22:43 PM CEST Arvind Yadav wrote:
> index df8ea79..ada9070 100644
> --- a/include/soc/fsl/qe/ucc_fast.h
> +++ b/include/soc/fsl/qe/ucc_fast.h
> @@ -165,10 +165,12 @@ struct ucc_fast_private {
>         int stopped_tx;         /* Whether channel has been stopped for Tx
>                                    (STOP_TX, etc.) */
>         int stopped_rx;         /* Whether channel has been stopped for Rx */
> -       u32 ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of Tx
> -                                                   virtual fifo */
> -       u32 ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of Rx
> -                                                   virtual fifo */
> +       unsigned long ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of
> +                                                           * Tx virtual fifo
> +                                                           */
> +       unsigned long ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of
> +                                                           * Rx virtual fifo
> +                                                           */
>  #ifdef STATISTICS
>         u32 tx_frames;          /* Transmitted frames counter. */
>         u32 rx_frames;          /* Received frames counter (only frames
> 

This change seems ok, but what about the other u32 variables in ucc_geth.c
that get checked for IS_ERR_VALUE?

	Arnd
