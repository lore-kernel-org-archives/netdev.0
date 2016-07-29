From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Fri, 29 Jul 2016 11:26:57 +0200
Message-ID: <4552489.XcKoxjnXeP@wuerfel>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com> <4697175.RMdFEWr9V5@wuerfel> <20160728131826.GA7582@Red>
Reply-To: arnd-r2nGTMty4D4@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDEKVJM7XAHRB3GC5S6AKGQE5NFSSIA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160728131826.GA7582@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Thursday, July 28, 2016 3:18:26 PM CEST LABBE Corentin wrote:
> 
> I will reworked locking and it seems that no locking is necessary.
> I have added the following comment about the locking strategy:
> 
> /* Locking strategy:
>  * RX queue does not need any lock since only sun8i_emac_poll() access it.
>  * (All other RX modifiers (ringparam/ndo_stop) disable NAPI and so sun8i_emac_poll())
>  * TX queue is handled by sun8i_emac_xmit(), sun8i_emac_complete_xmit() and sun8i_emac_tx_timeout()
>  * (All other RX modifiers (ringparam/ndo_stop) disable NAPI and stop queue)
>  *
>  * sun8i_emac_xmit() could fire only once (netif_tx_lock)
>  * sun8i_emac_complete_xmit() could fire only once (called from NAPI)
>  * sun8i_emac_tx_timeout() could fire only once (netif_tx_lock) and couldnt
>  * race with sun8i_emac_xmit (due to netif_tx_lock) and with sun8i_emac_complete_xmit which disable NAPI.
>  *
>  * So only sun8i_emac_xmit and sun8i_emac_complete_xmit could fire at the same time.
>  * But they never could modify the same descriptors:
>  * - sun8i_emac_complete_xmit() will modify only descriptors with empty status
>  * - sun8i_emac_xmit() will modify only descriptors set to DCLEAN
>  * Proper memory barriers ensure that descriptor set to DCLEAN could not be
>  * modified latter by sun8i_emac_complete_xmit().
>  * */

Sounds good, the comment is certainly very helpful here.

	Arnd
