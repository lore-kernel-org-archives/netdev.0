From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 20:58:22 +0100
Message-ID: <20120131195822.GA2175@polaris.bitmath.org>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com>
 <20120131192520.GA2974@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b21.telenor.se ([195.54.99.212]:37463 "EHLO
	smtprelay-b21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab2AaT5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 14:57:37 -0500
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-b21.telenor.se (Postfix) with ESMTP id 4F1AEEBEEF
	for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 20:57:36 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20120131192520.GA2974@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From 1f3587dd7cdb8e2a505c76041bd5b816e7bcfb67 Mon Sep 17 00:00:00 2001
> From: Henrik Rydberg <rydberg@euromail.se>
> Date: Tue, 31 Jan 2012 14:22:15 -0500
> Subject: [PATCH] bcma: don't fail for bad SPROM CRC
> 
> If it is OK ...?

How about this:

The brcmsmac driver is now using the bcma SPROM logic, which does not
recognize all chipsets that were functional prior to the switch. In
particular, the current code bails out on odd CRC errors in recent
Macbooks. This patch ignores those errors, with the argument that an
unrecognized SPROM should be treated similarly to a non-existing one.

> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> Henrik, may I add a Signed-off-by line for you?

By all means, thanks.

>  drivers/bcma/main.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
> index febbc0a..ec31f7d 100644
> --- a/drivers/bcma/main.c
> +++ b/drivers/bcma/main.c
> @@ -169,10 +169,8 @@ int bcma_bus_register(struct bcma_bus *bus)
>  	err = bcma_sprom_get(bus);
>  	if (err == -ENOENT) {
>  		pr_err("No SPROM available\n");
> -	} else if (err) {
> +	} else if (err)
>  		pr_err("Failed to get SPROM: %d\n", err);
> -		return -ENOENT;
> -	}
>  
>  	/* Register found cores */
>  	bcma_register_cores(bus);
> -- 
> 1.7.4.4

Henrik
