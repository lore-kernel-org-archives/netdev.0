From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.28 1/4] myri10ge: Stop scaring people when DCA is
 built but absent
Date: Sat, 13 Sep 2008 15:30:22 -0400
Message-ID: <48CC14CE.4050904@garzik.org>
References: <48CAAAEF.1060205@myri.com> <48CAAB2E.6010408@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbYIMTa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:30:27 -0400
In-Reply-To: <48CAAB2E.6010408@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Stop scaring people with what looks like a fatal message when DCA support
> is compiled into their kernel, but the DCA device is not present.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2008-08-29 07:29:45.000000000 +0200
> +++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2008-09-12 19:22:37.000000000 +0200
> @@ -1060,8 +1060,9 @@
>  	}
>  	err = dca_add_requester(&pdev->dev);
>  	if (err) {
> -		dev_err(&pdev->dev,
> -			"dca_add_requester() failed, err=%d\n", err);
> +		if (err != -ENODEV)
> +			dev_err(&pdev->dev,
> +				"dca_add_requester() failed, err=%d\n", err);
>  		return;

applied 1-4


