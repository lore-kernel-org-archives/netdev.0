From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] net: reduce net_rx_action() latency to 2 HZ
Date: Thu, 21 Mar 2013 11:03:18 -0400
Message-ID: <CAP=VYLrvXREA=HGnnUCi2N77yRdktQDop1PpzJkveXDihJ3DOw@mail.gmail.com>
References: <1362503713.15793.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1362503713.15793.121.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CC'ing stable & Willy - for the older releases not fed by
http://patchwork.ozlabs.org/bundle/davem/stable/ ]

On Tue, Mar 5, 2013 at 12:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazt@google.com>
>
> We should use time_after_eq() to get maximum latency of two ticks,
> instead of three.
>
> Bug added in commit 24f8b2385 (net: increase receive packet quantum)

I'm not sure what applications would notice the extra tick, but 24f8b takes
us back to 2.6.29.  It cherry picks cleanly onto 2.6.34, so it probably also
does the same for Willy's 2.6.32 longterm too.

Commit is now mainline d114a3338747255518 - v3.9-rc3~36^2~34.

Paul.
--

>
> Signed-off-by: Eric Dumazet <edumazt@google.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 18d8b5a..461b315 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4107,7 +4107,7 @@ static void net_rx_action(struct softirq_action *h)
>                  * Allow this to run for 2 jiffies since which will allow
>                  * an average latency of 1.5/HZ.
>                  */
> -               if (unlikely(budget <= 0 || time_after(jiffies, time_limit)))
> +               if (unlikely(budget <= 0 || time_after_eq(jiffies, time_limit)))
>                         goto softnet_break;
>
>                 local_irq_enable();
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
