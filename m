From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 6/7] net/faraday: Fix phy link irq on Aspeed G5
 SoCs
Date: Tue, 20 Sep 2016 15:14:03 +0300
Message-ID: <d4433fc6-1cda-3631-3fda-e3f41d05f27e@cogentembedded.com>
References: <20160920063007.24291-1-joel@jms.id.au>
 <20160920063007.24291-7-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gwshan@linux.vnet.ibm.com, andrew@lunn.ch, andrew@aj.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        benh@kernel.crashing.org
To: Joel Stanley <joel@jms.id.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34363 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbcITMOH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 08:14:07 -0400
Received: by mail-lf0-f53.google.com with SMTP id y6so11725857lff.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 05:14:06 -0700 (PDT)
In-Reply-To: <20160920063007.24291-7-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/20/2016 9:30 AM, Joel Stanley wrote:

> On Aspeed SoC with a direct PHY connection (non-NSCI), we receive
> continual PHYSTS interrupts:
>
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.280000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>  [   20.300000] ftgmac100 1e660000.ethernet eth0: [ISR] = 0x200: PHYSTS_CHG
>
> This is because the driver was enabling low-level sensitive interrupt
> generation where the systems are wired for high-level. All CPU cycles
> are spent servicing this interrupt.
>
> Signed-off-by: Joel Stanley <joel@jms.id.au>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 7ba0f2d58a8b..5466df028381 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -223,6 +223,10 @@ static void ftgmac100_start_hw(struct ftgmac100 *priv, int speed)
>  {
>  	int maccr = MACCR_ENABLE_ALL;
>
> +	if (of_machine_is_compatible("aspeed,ast2500")) {
> +		maccr &= ~FTGMAC100_MACCR_PHY_LINK_LEVEL;
> +	}

    {} not needed here.

[...]

MBR, Sergei
