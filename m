From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 9/9] tulip_core.c : out-of-bounds check.
Date: Fri, 13 Mar 2015 21:41:21 +0300
Message-ID: <55032F51.5090203@cogentembedded.com>
References: <1426256152-5522-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ameen Ali <ameenali023@gmail.com>, grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:40983 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbbCMSlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:41:25 -0400
Received: by labmn12 with SMTP id mn12so24508044lab.8
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 11:41:24 -0700 (PDT)
In-Reply-To: <1426256152-5522-1-git-send-email-ameenali023@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/13/2015 05:15 PM, Ameen Ali wrote:

> Array index 'j' is used before limits check.

> Suggest put limit check before index use.

> Signed-off-by : <Ameenali023@gmail.com>
> ---
>   drivers/net/ethernet/dec/tulip/tulip_core.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
> index 3b42556..ed41559 100644
> --- a/drivers/net/ethernet/dec/tulip/tulip_core.c
> +++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
> @@ -589,7 +589,7 @@ static void tulip_tx_timeout(struct net_device *dev)
>   			       (unsigned int)tp->rx_ring[i].buffer1,
>   			       (unsigned int)tp->rx_ring[i].buffer2,
>   			       buf[0], buf[1], buf[2]);
> -			for (j = 0; buf[j] != 0xee && j < 1600; j++)
> +			for (j = 0; ((j < 1600) && buf[j] != 0xee); j++)

    No need for extra parens, either around < or around &&.

WBR, Sergei
