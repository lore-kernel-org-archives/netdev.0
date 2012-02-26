From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2] ARM: LPC32xx: Ethernet driver
Date: Sun, 26 Feb 2012 03:52:18 +0200
Message-ID: <20120226015217.GA3257@tarshish>
References: <1330201304-24037-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:40846 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396Ab2BZBxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 20:53:34 -0500
Content-Disposition: inline
In-Reply-To: <1330201304-24037-1-git-send-email-stigge@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland,

On Sat, Feb 25, 2012 at 09:21:44PM +0100, Roland Stigge wrote:
> This patch adds an ethernet driver for the LPC32xx ARM SoC.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>

[snip]

> +static int __init ethaddr(char *s)
> +{
> +	int i;
> +	unsigned int r[6];
> +
> +	sscanf(s, "%x:%x:%x:%x:%x:%x",
> +			&r[0], &r[1], &r[2], &r[3], &r[4], &r[5]);
> +	for (i = 0; i < 6; i++)
> +		mac_address[i] = (u8)r[i];
> +
> +	return 1;
> +}
> +__setup("ethaddr=", ethaddr);

Please use a module_param() instead of a top level kernel parameter.

You may also consider using module_param_array() here. See 
drivers/net/ethernet/freescale/fec.c for an example. Note, however, that this 
changes the format the MAC address representation. Instead of 
"01:02:03:04:05:06", use "0x01,0x02,0x03,0x04,0x05,0x06".

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
