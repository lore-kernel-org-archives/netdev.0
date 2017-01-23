From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH] net: stmicro: fix LS field mask in EEE configuration
Date: Mon, 23 Jan 2017 11:01:08 +0530
Message-ID: <CAJ3bTp5hcodw9C5Rs6OowFg4D28e4AnseMXG8agxs+0chTnW9w@mail.gmail.com>
References: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36695 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWFbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 00:31:10 -0500
Received: by mail-wm0-f51.google.com with SMTP id c85so115546590wmi.1
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 21:31:09 -0800 (PST)
In-Reply-To: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by:Rayagond Kokatanur <rayagond@vayavyalabs.com>

On Fri, Jan 20, 2017 at 9:30 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
> This patch fixes the LS mask when setting EEE timer.
> LS field is 10 bits long and not 11 as currently.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> Reported-By: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 834f40f..202216c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -184,7 +184,7 @@ static void dwmac4_set_eee_pls(struct mac_device_info *hw, int link)
>  static void dwmac4_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
>  {
>         void __iomem *ioaddr = hw->pcsr;
> -       int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
> +       int value = ((tw & 0xffff)) | ((ls & 0x3ff) << 16);
>
>         /* Program the timers in the LPI timer control register:
>          * LS: minimum time (ms) for which the link
> --
> 2.9.3
>



-- 
wwr
Rayagond
