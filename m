From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v5, 2/6] fsl/fman: Add FMan support
Date: Thu, 1 Oct 2015 22:35:06 -0500
Message-ID: <20151002033506.GA8067@home.buserror.net>
References: <1443085838-7539-1-git-send-email-igal.liberman@freescale.com>
 <1443085838-7539-3-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <madalin.bucur@freescale.com>,
	<pebolle@tiscali.nl>, <joakim.tjernlund@transmode.se>,
	<ppc@mindchasers.com>, <stephen@networkplumber.org>,
	<davem@davemloft.net>
To: <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443085838-7539-3-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 12:10:34PM +0300, igal.liberman@freescale.com wrote:
> +int fman_get_rx_extra_headroom(void)
> +{
> +	static bool fm_check_rx_extra_headroom;
> +
> +	if (!fm_check_rx_extra_headroom) {
> +		if (fsl_fm_rx_extra_headroom > FSL_FM_RX_EXTRA_HEADROOM_MAX ||
> +		    fsl_fm_rx_extra_headroom < FSL_FM_RX_EXTRA_HEADROOM_MIN) {
> +			pr_warn("Invalid fsl_fm_rx_extra_headroom value (%d) in bootargs, valid range is %d-%d. Falling back to the default (%d)\n",
> +				fsl_fm_rx_extra_headroom,
> +				FSL_FM_RX_EXTRA_HEADROOM_MIN,
> +				FSL_FM_RX_EXTRA_HEADROOM_MAX,
> +				FSL_FM_RX_EXTRA_HEADROOM);
> +			fsl_fm_rx_extra_headroom = FSL_FM_RX_EXTRA_HEADROOM;
> +		}
> +
> +		fsl_fm_rx_extra_headroom = true;

I think you mean "fm_check_rx_extra_headroom = true".

> +		fsl_fm_rx_extra_headroom = ALIGN(fsl_fm_rx_extra_headroom, 16);
> +	}
> +
> +	return fsl_fm_rx_extra_headroom;
> +}
> +EXPORT_SYMBOL(fman_get_rx_extra_headroom);

Please just check things like this once during module init. 
Init-on-first-use is unnecessarily complicated, and race-prone.

-Scott
