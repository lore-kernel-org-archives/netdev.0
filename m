From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/3] Enable PPS and PTP clocks automatically
Date: Thu, 1 Nov 2012 09:19:24 +0100
Message-ID: <20121101081924.GB2637@netboy.at.omicron.at>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42686 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab2KAITf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 04:19:35 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1140674eek.19
        for <netdev@vger.kernel.org>; Thu, 01 Nov 2012 01:19:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

I really like this idea, but I have a couple of questions, below.

On Thu, Nov 01, 2012 at 01:29:57AM +0000, Ben Hutchings wrote:

> Ben Hutchings (3):
>   pps, ptp: Remove dependencies on EXPERIMENTAL

Kees Cook just posted a massive series to remove EXPERIMENTAL
everywhere. Maybe it would make sense to have this series follow that
one?

>   ptp: Make PTP_1588_CLOCK select rather than depend on PPS
>   ptp: Enable clock drivers along with associated net/PHY drivers
> 
>  drivers/net/ethernet/intel/Kconfig                 |   28 +------------------
>  drivers/net/ethernet/intel/igb/Makefile            |    4 +--
>  drivers/net/ethernet/intel/igb/igb.h               |    6 ----
>  drivers/net/ethernet/intel/igb/igb_ethtool.c       |    2 -
>  drivers/net/ethernet/intel/igb/igb_main.c          |   28 --------------------

The #ifdefs in the Intel and PCH drivers are meant to streamline the
code for users who are not interested in time stamping. Although the
overhead of the additional is minimal (it really just a bunch of
tests), and I wouldn't mind removing the conditionals, I suspect that
some people won't like it.

>  drivers/net/ethernet/intel/ixgbe/Makefile          |    3 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    6 ----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    2 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   28 --------------------
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   16 -----------
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 -
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   14 ----------

Thanks,
Richard
