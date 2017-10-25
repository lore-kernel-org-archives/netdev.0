From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: Re: [PATCH] drivers/net: hippi: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 08:58:41 -0400
Message-ID: <7bfcf28f-749c-8b7a-a999-54054d15c766@gmail.com>
References: <20171025105129.GA146547@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, linux-hippi@sunsite.dk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:49161 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdJYM6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 08:58:44 -0400
In-Reply-To: <20171025105129.GA146547@beast>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2017 06:51 AM, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Jes Sorensen <jes@trained-monkey.org>
> Cc: linux-hippi@sunsite.dk
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>   drivers/net/hippi/rrunner.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)

Looks good to me.

Jes

> diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
> index 76cc140774a2..8483f03d5a41 100644
> --- a/drivers/net/hippi/rrunner.c
> +++ b/drivers/net/hippi/rrunner.c
> @@ -1146,10 +1146,10 @@ static inline void rr_raz_rx(struct rr_private *rrpriv,
>   	}
>   }
>   
> -static void rr_timer(unsigned long data)
> +static void rr_timer(struct timer_list *t)
>   {
> -	struct net_device *dev = (struct net_device *)data;
> -	struct rr_private *rrpriv = netdev_priv(dev);
> +	struct rr_private *rrpriv = from_timer(rrpriv, t, timer);
> +	struct net_device *dev = pci_get_drvdata(rrpriv->pci_dev);
>   	struct rr_regs __iomem *regs = rrpriv->regs;
>   	unsigned long flags;
>   
> @@ -1229,7 +1229,7 @@ static int rr_open(struct net_device *dev)
>   
>   	/* Set the timer to switch to check for link beat and perhaps switch
>   	   to an alternate media type. */
> -	setup_timer(&rrpriv->timer, rr_timer, (unsigned long)dev);
> +	timer_setup(&rrpriv->timer, rr_timer, 0);
>   	rrpriv->timer.expires = RUN_AT(5*HZ);           /* 5 sec. watchdog */
>   	add_timer(&rrpriv->timer);
>   
> 
