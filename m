From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] {iproute2, xfrm}: Use memcpy to suppress gcc phony
 buffer overflow warning
Date: Mon, 30 Sep 2013 21:10:41 -0700
Message-ID: <20130930211041.38836334@nehalam.linuxnetplumber.net>
References: <524411AE.7000404@linux.vnet.ibm.com>
	<52447DAC.2060701@linux.vnet.ibm.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com>
	<5246D88F.7090906@linux.vnet.ibm.com>
	<52478710.702@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	David Laight <David.Laight@aculab.com>,
	<netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45728 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3JAEKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:10:45 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so6623849pde.37
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 21:10:44 -0700 (PDT)
In-Reply-To: <52478710.702@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> index 0d98e78..5cc87d3 100644
> --- a/ip/xfrm_state.c
> +++ b/ip/xfrm_state.c
> @@ -159,7 +159,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
>   			if (len > max)
>   				invarg("\"ALGO-KEY\" makes buffer overflow\n", key);
> 
> -			strncpy(buf, key, len);
> +			memcpy(buf, key, len);
>   		}
>   	}
> 

Applied this patch. With some edits to make commit message logical.
