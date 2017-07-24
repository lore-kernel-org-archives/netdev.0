From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH 1/2] ftgmac100: Increase reset timeout
Date: Mon, 24 Jul 2017 22:39:52 +0930
Message-ID: <CACPK8XdUJK8x7Zc1nLceSpM-Bt0zW13F-OGTJKrNgGGxFtY76w@mail.gmail.com>
References: <20170724065917.5F9AEC6037@b03ledav006.gho.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Joel Stanley <joel.stanley@au1.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34972 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753218AbdGXNKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:10:14 -0400
Received: by mail-yw0-f193.google.com with SMTP id l82so1471193ywc.2
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 06:10:13 -0700 (PDT)
In-Reply-To: <20170724065917.5F9AEC6037@b03ledav006.gho.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 4:29 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> We had reports of 50us not being sufficient to reset the MAC,
> thus hitting the "Hardware reset failed" error bringing the
> interface up on some AST2400 based machines.
>
> This bumps the timeout to 200us.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

I gave this a spin on the problematic hardware, as well as a few other
machines. Looks good, thanks Ben.

Tested-by: Joel Stanley <joel@jms.id.au>

Cheers,

Joel


> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index b166666128d3..2b17f7023d91 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -125,7 +125,7 @@ static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
>         iowrite32(maccr, priv->base + FTGMAC100_OFFSET_MACCR);
>         iowrite32(maccr | FTGMAC100_MACCR_SW_RST,
>                   priv->base + FTGMAC100_OFFSET_MACCR);
> -       for (i = 0; i < 50; i++) {
> +       for (i = 0; i < 200; i++) {
>                 unsigned int maccr;
>
>                 maccr = ioread32(priv->base + FTGMAC100_OFFSET_MACCR);
