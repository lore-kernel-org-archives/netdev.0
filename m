From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] pch_gbe: Fix PTP dependencies.
Date: Fri, 5 Oct 2012 15:04:16 +0200
Message-ID: <20121005130416.GA2088@netboy.at.omicron.at>
References: <20121002.223504.1130795240955330652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62737 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab2JENEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 09:04:21 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1031527wey.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 06:04:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121002.223504.1130795240955330652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 02, 2012 at 10:35:04PM -0400, David Miller wrote:
> 
> The config combination:
> 
>         CONFIG_PCH_GBE=y
>         CONFIG_PCH_PTP=y
>         CONFIG_PTP_1588_CLOCK=m
...
> @@ -26,7 +26,7 @@ if PCH_GBE
>  config PCH_PTP
>  	bool "PCH PTP clock support"
>  	default n
> -	depends on PTP_1588_CLOCK_PCH
> +	select PTP_1588_CLOCK_PCH

Based on Fengguang Wu's complaint, maybe this would work better:

	depends on PTP_1588_CLOCK && !(PCH_GBE=y && PTP_1588_CLOCK=m)

Thanks,
Richard
