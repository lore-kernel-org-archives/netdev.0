From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 22:30:34 +0200
Message-ID: <470E87EA.4030200@trash.net>
References: <1192127132.4732.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36777 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbXJKUax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 16:30:53 -0400
In-Reply-To: <1192127132.4732.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Henriksson wrote:
> Abort flush after 10 seconds.

This should be optional IMO.

> Add references to lartc, also drop bogus reference to tc-filters

There's a bad habit of reporting bugs on lartc that belong to netdev,
please also make it perfectly clear that lartc is not for bug-reports.

> Fix overflow in time2tick / tick2time.
> 
> The helper functions gets passed an unsigned int, which gets cast to long
> and overflows.
> 
> See Debian bug #175462 - http://bugs.debian.org/175462
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> 
> diff -uri iproute-20070313.orig/tc/tc_core.c iproute-20070313/tc/tc_core.c
> --- iproute-20070313.orig/tc/tc_core.c	2007-03-13 22:50:56.000000000 +0100
> +++ iproute-20070313/tc/tc_core.c	2007-08-15 00:41:30.000000000 +0200
> @@ -35,12 +35,12 @@
>  }
>  
>  
> -long tc_core_time2tick(long time)
> +unsigned tc_core_time2tick(unsigned time)
>  {
>  	return time*tick_in_usec;
>  }
>  
> -long tc_core_tick2time(long tick)
> +unsigned tc_core_tick2time(unsigned tick)
>  {
>  	return tick/tick_in_usec;
>  }

What about the other functions returning long? I think all of these
should be unsigned.
