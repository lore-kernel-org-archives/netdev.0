From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] (1/4) netem - update API for new features
Date: 26 Aug 2004 08:08:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093522131.1043.84.camel@jzny.localdomain>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-08-25 at 13:53, Stephen Hemminger wrote:
> Extend netem options to support new features.
> 

>  struct tc_netem_qopt
>  {
>  	__u32	latency;	/* added delay (us) */
> @@ -409,6 +410,13 @@
>  	__u32	loss;		/* random packet loss (0=none ~0=100%) */
>  	__u32	gap;		/* re-ordering gap (0 for delay all) */
>  	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
> -	__u32	jitter;		/* random jitter in latency (us) */
> +	__u32	jitter;		/* delay sigma (us) */
> +
> +	__u32	delay_corr;	/* delay correllation (0=none ~0=100%) */
> +	__u32	loss_corr;	/* packet loss correllation (0=none ~0=100%) */
> +	__u32	dup_corr;	/* duplicate correlation (0=none ~0=100%) */
> +
> +	__s16	delay_dist[0];	/* delay distribution table (optional) */
> +#define TCA_NETEM_TABLEFACTOR	8192
>  };

You should really send the delay_dist in its own TLV to avoid
the kind of mistakes that showed up in u32 classifier.
Also allows you to extend that structure in the future.

cheers,
jamal

PS:- kudos on moving that stuff to user space.
