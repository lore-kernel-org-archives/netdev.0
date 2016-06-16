From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/8] net: gianfar: fix old-style declaration
Date: Thu, 16 Jun 2016 21:02:01 +0300
Message-ID: <0d9320db-ae2c-03a2-eb20-e527a69c356b@cogentembedded.com>
References: <20160616135020.3154461-1-arnd@arndb.de>
 <20160616135245.3198419-1-arnd@arndb.de>
 <20160616135245.3198419-6-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Yangbo Lu <yangbo.lu@nxp.com>, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135245.3198419-6-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/16/2016 04:52 PM, Arnd Bergmann wrote:

> Modern C standards expect the '__inline__' keyword to come before the return
> type in a declaration, and we get a warning for this with "make W=1":
>
> drivers/net/ethernet/freescale/gianfar.c:2278:1: error: 'inline' is not at beginning of declaration [-Werror=old-style-declaration]
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/freescale/gianfar.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 2e6785b6e8be..d20935dc8399 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2275,7 +2275,7 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
>  	fcb->flags = flags;
>  }
>
> -void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
> +static inline void gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)

    You don't mention making it *static*. Though the function can be *static* 
indeed... the current policy also forbids *inline* in the *.c files, leaving 
the judgement to gcc.

MBR, Sergei
