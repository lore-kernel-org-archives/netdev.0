From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: implement rx_copybreak to improve rx
 performance
Date: Mon, 29 Sep 2014 05:12:19 -0700
Message-ID: <1411992739.30721.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411976824-28824-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, davem@davemloft.net, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:54726 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbaI2MMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 08:12:21 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so4346820pad.2
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 05:12:21 -0700 (PDT)
In-Reply-To: <1411976824-28824-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-29 at 15:47 +0800, Fugang Duan wrote:
> - Copy short frames and keep the buffers mapped, re-allocate skb instead of
>   memory copy for long frames.
> - Add support for setting/getting rx_copybreak using generic ethtool tunable
> 
> Changes V2:
> * Implements rx_copybreak

>  
> +#define COPYBREAK_DEFAULT 256
> +static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
> +module_param(copybreak, uint, 0644);
> +MODULE_PARM_DESC(copybreak,
> +		 "Maximum packet size that is copied to a new buffer on receive");
> +

It is not the right way to handle this.

Old drivers might still have a legacy module parameter.

New implementations should provide the new ethtool support, and only
this. No new module parameter is accepted.

For details, check following commits :

d4ad30b182305ecf97f145a5d4d1fd9e728c6d01 enic: Add tunable_ops support
for rx_copybreak

f0db9b073415848709dd59a6394969882f517da9 ethtool: Add generic options
for tunables


Or check the current tree :

git grep -n rx_copybreak drivers/net/ethernet/cisco/enic
