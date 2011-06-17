From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/4] r8169: support new firmware format.
Date: Fri, 17 Jun 2011 22:15:08 +0100
Message-ID: <1308345308.2831.33.camel@bwh-desktop>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
	 <20110617193133.GC2287@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3893 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab1FQVPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:15:12 -0400
In-Reply-To: <20110617193133.GC2287@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 21:31 +0200, Francois Romieu wrote:
> The new firmware format adds versioning as firmware for a specific
> chipset appears to be subject to change. Current "legacy" format is
> still supported.
[...]
>  static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
>  {
[...] 
> -	if (!(fw->size % FW_OPCODE_SIZE)) {
> +	if (fw->size < FW_OPCODE_SIZE)
> +		goto out;
[...]
> +		if (fw->size % FW_OPCODE_SIZE)
> +			goto out;
> +
[...]
> -
> +out:
>  	return rc;
>  }

These changes belong in patch 2/4.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

