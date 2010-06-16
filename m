From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 04/12] phylib: add a way to make PHY time stamps possible.
Date: Wed, 16 Jun 2010 08:29:40 +0200
Message-ID: <20100616062940.GC2887@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 06:08:20PM +0200, Richard Cochran wrote:

> +static inline void skb_tx_timetamp(struct phy_device *phy, struct sk_buff *skb)
> +{
> +	union skb_shared_tx *shtx = skb_tx(skb);
> +
> +	if (shtx->hardware && phy && phy->drv->txtstamp)
> +		phy->drv->txtstamp(phy, skb);
> +
> +	if (shtx->software && !shtx->in_progress)
> +		skb_tstamp_tx(skb, NULL);
> +}

I forgot to mention this patch also provides a way to fix the broken
software timestamp fallback mode of the SO_TIMESTAMPING API.

We would have to add this inline call to every MAC driver in an
appropriate spot within the hard_xmit function. It is not too pretty,
but providing this as a compile time option will promote
standardization of the SO_TIMESTAMPING API for applications.

Richard
