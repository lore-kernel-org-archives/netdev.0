From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware timestamp
 support
Date: Wed, 06 Aug 2014 18:05:50 +0400
Message-ID: <53E2363E.9040208@cogentembedded.com>
References: <ef09199e48ab4d4a80c4ba554c9e3853@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
	Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ef09199e48ab4d4a80c4ba554c9e3853@FE-MBX1012.de.bosch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/6/2014 5:56 PM, Koehrer Mathias (ETAS/ESW5) wrote:

> With the Intel 82527EI (driver: e1000e) there is an issue when running the ptpd2 program, that leads to a kernel oops.
> The reason is here that in e1000_xmit_frame() a work queue will be scheduled that has not been initialized in this case.
> The work queue "tx_hwstamp_work" will only be initialized if adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
> This check is missing in e1000_xmit_frame().

   Please wrap your changelog at 80 columns or less.

> The following patch adds the missing check.

> Signed-off-by: Mathias Koehrer <mathias.koehrer@etas.com>
> ---
>   drivers/net/ethernet/intel/e1000e/netdev.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)

> Index: linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c
> ===================================================================
> --- linux-3.12.26.orig/drivers/net/ethernet/intel/e1000e/netdev.c       2014-08-04 10:56:56.000000000 +0200
> +++ linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c    2014-08-06 15:15:42.000000000 +0200
> @@ -5549,7 +5549,8 @@
>          count = e1000_tx_map(tx_ring, skb, first, adapter->tx_fifo_limit,
>                               nr_frags);
>          if (count) {
> -               if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&

    Your mailer has corrupted the patch -- all tabs were converted to spaces.

> +               if ((adapter->flags & FLAG_HAS_HW_TIMESTAMP) &&
> +                        unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&

    When you break the line with the *if* statement, continuation lines should 
start on a column right after ( above, according to the networking coding style.

WBR, Sergei
