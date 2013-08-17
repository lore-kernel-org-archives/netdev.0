From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode
 if platform data force_sf_dma_mode is negative.
Date: Fri, 16 Aug 2013 22:30:51 -0700 (PDT)
Message-ID: <20130816.223051.1755449989011656134.davem@davemloft.net>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
	<20130815.142005.816948927496553829.davem@davemloft.net>
	<CAJxxZ0Pya_K-VJcAZ6yv00_F66uAd481vWgV-nWmPBWKOV760A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab3HQFaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 01:30:52 -0400
In-Reply-To: <CAJxxZ0Pya_K-VJcAZ6yv00_F66uAd481vWgV-nWmPBWKOV760A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Fri, 16 Aug 2013 17:37:42 +0800

> Hi David,
> 
> On Fri, Aug 16, 2013 at 5:20 AM, David Miller <davem@davemloft.net> wrote:
>> From: Sonic Zhang <sonic.adi@gmail.com>
>> Date: Thu, 15 Aug 2013 15:37:36 +0800
>>
>>> @@ -1157,7 +1157,9 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>>>   */
>>>  static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>>>  {
>>> -     if (likely(priv->plat->force_sf_dma_mode ||
>>> +     if (priv->plat->force_sf_dma_mode < 0)
>>> +             priv->hw->dma->dma_mode(priv->ioaddr, tc, tc);
>>> +     else if (likely(priv->plat->force_sf_dma_mode > 0 ||
>>>                  ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {
>>
>> You need to properly re-indent the last line here so that
>> the openning parenthesis lines up with the first column
>> after the openning parenthesis on the "else if" line.
> 
> The last line is the original source code in master branch of the
> Linus's kernel git tree. Do you mean I should fix the ident issue in
> this patch as well?

I'm saying that, in your patch, the second line in

+     else if (likely(priv->plat->force_sf_dma_mode > 0 ||
                 ((priv->plat->tx_coe) && (!priv->no_csum_insertion)))) {

need to be reindented because you're moving the openning parenthesis
to the left by several columns, therefore the second line needs to move
the same amount.
