From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 2/2] r8169: support RTL8168G
Date: Wed, 04 Jul 2012 17:51:47 -0700
Message-ID: <1341449507.2058.6.camel@joe2Laptop>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com>
	 <1341221002-1522-1-git-send-email-hayeswang@realtek.com>
	 <1341221002-1522-2-git-send-email-hayeswang@realtek.com>
	 <20120704220458.GA1621@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:44262 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751359Ab2GEAvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2012 20:51:48 -0400
In-Reply-To: <20120704220458.GA1621@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 00:04 +0200, Francois Romieu wrote:
> Hayes Wang <hayeswang@realtek.com> :
> > Support the new chip RTL8168G.

> - save Joe P. some work

Thanks.  Just a trivial thing below:

[]

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
[]
> +#define	RTL_LOOP_MAX	10000
> +
> +static void rtl_mcu_wait_list_ready(void __iomem *ioaddr)
> +{
> +	int i;
> +
> +	for (i = 0; i < RTL_LOOP_MAX; i++) {
> +		if (RTL_R8(MCU) & LINK_LIST_RDY)
> +			return;
> +		udelay(100);
> +	}
> +}

This pattern is used a couple more times.
There's no failure handling either.

Maybe use a macro with RTL_R8/32, register and test?
Maybe the delays could be tuned out a bit better.
Maybe a continuous read or a less frequent read
might be better.

>  static void __devinit rtl_hw_init_8168g(struct rtl8169_private *tp)
>  {
[]
> +	for (i = 0; i < RTL_LOOP_MAX; i++) {
> +		if (RTL_R32(TxConfig) & TXCFG_EMPTY)
> +			break;
>  		udelay(100);
> +	}

pattern

> +	for (i = 0; i < RTL_LOOP_MAX; i++) {
> +		if ((RTL_R8(MCU) & RXTX_EMPTY) == RXTX_EMPTY)
> +			break;
>  		udelay(100);
> +	}

pattern
