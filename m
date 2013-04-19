From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check
 which device is active
Date: Fri, 19 Apr 2013 17:10:46 +0400
Message-ID: <51714256.6030504@cogentembedded.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, "David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:53659 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030298Ab3DSNL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 09:11:58 -0400
Received: by mail-lb0-f171.google.com with SMTP id v10so3693647lbd.2
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 06:11:56 -0700 (PDT)
In-Reply-To: <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-04-2013 1:52, Sebastian Andrzej Siewior wrote:

> netif_running() reports false before even the ->ndo_stop() callback is
> called. That means if one executes "ifconfig down" and the system
> receives an interrupt before the interrupt source has been disabled we
> hang for always for two reasons:
> - we never disable the interrupt source because devices claim to be
>    already inactive (or non-present)
> - since the ISR always reports IRQ_HANDLED the line is never deactivated
>    because it looks like the ISR feels respsonsible.

> This patch introduces now the ->active field which is set/cleared in
> ndo_open / ndo_stop.

> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   26 +++++++++++++++++---------
>   1 file changed, 17 insertions(+), 9 deletions(-)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 3b22a36..c32780d 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -341,6 +341,7 @@ struct cpsw_priv {
>   	int				host_port;
>   	struct clk			*clk;
>   	u8				mac_addr[ETH_ALEN];
> +	u8				active;

    *bool* seems to fit better here.

WBR, Sergei
