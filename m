From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] r8169: Filtered data on Rx descriptor status context
Date: Sun, 9 Aug 2015 15:41:23 +0300
Message-ID: <55C74A73.9080100@cogentembedded.com>
References: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:34923 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932983AbbHIMl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 08:41:26 -0400
Received: by lbbpo9 with SMTP id po9so82440790lbb.2
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 05:41:25 -0700 (PDT)
In-Reply-To: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/9/2015 2:57 PM, Corcodel Marian wrote:

>   We want to start evaluate an RES Receive error summary only
>   when LS (LastFrag) occurred but without FirstFrag


> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 8bf8c3f..0ee0107 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7305,12 +7305,15 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
>   		if (status & DescOwn)
>   			break;
>
> +		if (!(status & LastFrag))
> +			break;
> +
>   		/* This barrier is needed to keep us from reading
>   		 * any other fields out of the Rx descriptor until
>   		 * we know the status of DescOwn
>   		 */
>   		dma_rmb();
> -
> +               if (!(status & FirstFrag)) {
>   		if (unlikely(status & RxRES)) {
>   			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
>   				   status);
> @@ -7323,6 +7326,7 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
>   				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
>   				dev->stats.rx_fifo_errors++;
>   			}
> +	       }

    This won't do, you should reindent the code.

MBR, Sergei
