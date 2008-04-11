From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Fri, 11 Apr 2008 14:51:05 +0200
Message-ID: <47FF5EB9.2010108@trash.net>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk> <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53601 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758030AbYDKMvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 08:51:09 -0400
In-Reply-To: <Pine.LNX.4.64.0804092259460.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> @@ -87,6 +111,16 @@ int tc_calc_rtable(struct tc_ratespec *r, __u32 
> *rtab, int cell_log, unsigned mt
>          unsigned sz = ((i+1)<<cell_log);
>          if (sz < mpu)
>              sz = mpu;
> +        switch (linklayer) {
> +        case LINKLAYER_ATM:
> +            sz = tc_align_to_atm(sz);
> +            break;
> +        case LINKLAYER_ETHERNET:
> +            // No size adjustments on Ethernet
> +            break;

Couldn't this use the ARPHRD values?
