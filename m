From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Flow control frames recorded as dropped packets
Date: Wed, 3 Feb 2010 09:10:50 -0800
Message-ID: <20100203091050.2a734a3e@nehalam>
References: <4B69AAA9.20505@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35646 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757427Ab0BCRLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2010 12:11:03 -0500
In-Reply-To: <4B69AAA9.20505@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Feb 2010 11:56:09 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> When a flow control packet is received, sky2_receive resubmits the i/o. 
> Upon exit, sky2_status_intr counts these as dropped packets.
> 
> This fix just skips the rx_dropped accounting in this one case. It 
> didn't seem worthwhile to change sky2_receive to deal differently.
> 
> This is my first patch submission - comments more than welcome.
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 95fd10f..bcb035c 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2525,7 +2517,8 @@ static int sky2_status_intr(struct sky2_hw *hw, 
> int to_do, u16 idx)
>                          total_bytes[port] += length;
>                          skb = sky2_receive(dev, length, status);
>                          if (unlikely(!skb)) {
> -                               dev->stats.rx_dropped++;
> +                               if (!(status & GMR_FS_GOOD_FC) )
> +                                       dev->stats.rx_dropped++;
>                                  break;
>                          }
> 

Since FC should be absorbed by MAC, it would be better to never receive
send them up stream. I'll make a patch for that
-- 
