From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Wed, 20 Jul 2016 11:56:12 +0200
Message-ID: <4697175.RMdFEWr9V5@wuerfel>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com> <1469001800-11615-2-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: arnd-r2nGTMty4D4@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-sunxi+bncBDEKVJM7XAHRBSEVXW6AKGQEDG4YYMY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1469001800-11615-2-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Wednesday, July 20, 2016 10:03:16 AM CEST LABBE Corentin wrote:
> +
> +       /* Benched on OPIPC with 100M, setting more than 256 does not give any
> +        * perf boost
> +        */
> +       priv->nbdesc_rx = 128;
> +       priv->nbdesc_tx = 256;
> +
> 

256 tx descriptors can introduce a significant latency. Can you add
support for BQL (netdev_sent_queue/netdev_completed_queue) to limit
the queue size to the minimum?

I also noticed that your tx_lock() prevents you from concurrently
running sun8i_emac_complete_xmit() and sun8i_emac_xmit(). Is that
necessary? I'd think that you can find a way to make them work
concurrently.

	Arnd
