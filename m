From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2] coccinelle: api: check for propagation of error from
 platform_get_irq
Date: Sun, 27 Dec 2015 01:26:36 +0300
Message-ID: <567F141C.8010000@cogentembedded.com>
References: <1451157891-24881-1-git-send-email-Julia.Lawall@lip6.fr>
 <567EF188.7020203@cogentembedded.com>
 <alpine.DEB.2.02.1512262107340.2070@localhost6.localdomain6>
 <alpine.DEB.2.02.1512262123500.2070@localhost6.localdomain6>
 <567EF895.6080702@cogentembedded.com>
 <alpine.DEB.2.02.1512262156580.2070@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	Gilles Muller <Gilles.Muller-L2FTfq7BK8M@public.gmane.org>,
	Nicolas Palix <nicolas.palix-wMUr/XMoy4A@public.gmane.org>,
	Michal Marek <mmarek-IBi9RG/b67k@public.gmane.org>, cocci-/FJkirnvOdkvYVN+rsErww@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.02.1512262156580.2070-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/26/2015 11:58 PM, Julia Lawall wrote:

> The error return value of platform_get_irq seems to often get dropped.
>
> Signed-off-by: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
>
> ---
>
> v2: Check for the direct return case also.  Added some mailing lists of
> common offenders.
>
> diff --git a/scripts/coccinelle/api/platform_get_irq_return.cocci b/scripts/coccinelle/api/platform_get_irq_return.cocci
> new file mode 100644
> index 0000000..44680d0
> --- /dev/null
> +++ b/scripts/coccinelle/api/platform_get_irq_return.cocci
> @@ -0,0 +1,58 @@
> +/// Propagate the return value of platform_get_irq.
> +//# Sometimes the return value of platform_get_irq is tested using <= 0, but 0
> +//# might not be an appropriate return value in an error case.
> +///
> +// Confidence: Moderate
> +// Copyright: (C) 2015 Julia Lawall, Inria. GPLv2.
> +// URL: http://coccinelle.lip6.fr/
> +// Options: --no-includes --include-headers
> +
> +virtual context
> +virtual org
> +virtual report
> +
> +// ----------------------------------------------------------------------------
> +
> +@r depends on context || org || report@
> +constant C;
> +statement S;
> +expression e, ret;
> +position j0, j1;
> +@@
> +
> +* e@j0 = platform_get_irq(...);
> +(
> +if@j1 (...) {
> +  ...
> +  return -C;
> +} else S
> +|
> +if@j1 (...) {
> +  ...
> +  ret = -C;
> +  ...
> +  return ret;
> +} else S

    Well, this seems to also cover the (e <= 0) checks which do make same 
sense in the light of Linus considering IRQ0 invalid. So I'd be more specific 
about the checks here -- 0 should indeed be overridden with something if it's 
considered invalid.

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
