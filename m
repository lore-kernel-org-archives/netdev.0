From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode if
 platform data force_sf_dma_mode is negative.
Date: Fri, 16 Aug 2013 17:37:42 +0800
Message-ID: <CAJxxZ0Pya_K-VJcAZ6yv00_F66uAd481vWgV-nWmPBWKOV760A@mail.gmail.com>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
	<20130815.142005.816948927496553829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:57693 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946Ab3HPJhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 05:37:43 -0400
Received: by mail-oa0-f49.google.com with SMTP id n10so1997245oag.36
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 02:37:42 -0700 (PDT)
In-Reply-To: <20130815.142005.816948927496553829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Aug 16, 2013 at 5:20 AM, David Miller <davem@davemloft.net> wrote:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Thu, 15 Aug 2013 15:37:36 +0800
>
>> @@ -1157,7 +1157,9 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>>   */
>>  static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>>  {
>> -     if (likely(priv->plat->force_sf_dma_mode ||
>> +     if (priv->plat->force_sf_dma_mode < 0)
>> +             priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
>> +     else if (likely(priv->plat->force_sf_dma_mode > 0 ||
>>                  ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
>
> You need to properly re-indent the last line here so that
> the openning parenthesis lines up with the first column
> after the openning parenthesis on the "else if" line.

The last line is the original source code in master branch of the
Linus's kernel git tree. Do you mean I should fix the ident issue in
this patch as well?


Regards,

Sonic
