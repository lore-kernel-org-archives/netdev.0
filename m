From: Alexandru Ardelean <ardeleanalex@gmail.com>
Subject: Re: [PATCH] net/fsl: remove func xgmac_wait_until_free() as duplicate
Date: Tue, 9 May 2017 09:56:38 +0300
Message-ID: <CA+U=DsrcLTZ_kPvJf8jtWoB63cxOcN5_j5ouebC0xtHN6OjoPg@mail.gmail.com>
References: <1494243078-17917-1-git-send-email-ardeleanalex@gmail.com> <20170508.153414.1871607886646871422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34657 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbdEIG5A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 02:57:00 -0400
Received: by mail-pg0-f68.google.com with SMTP id u187so13856622pgb.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 23:57:00 -0700 (PDT)
In-Reply-To: <20170508.153414.1871607886646871422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 10:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexandru Ardelean <ardeleanalex@gmail.com>
> Date: Mon,  8 May 2017 14:31:18 +0300
>
>> Looking at xgmac_wait_until_done() and xgmac_wait_until_free()
>> functions, they seem to have turned out completely identical.
>>
>> Though, judging from the git history it seems they
>> initially weren't.
>>
>> Remove xgmac_wait_until_free() in favor of xgmac_wait_until_done().
>>
>> Signed-off-by: Alexandru Ardelean <ardeleanalex@gmail.com>
>
> This situation got created by the commit below, I wonder if it
> is even correct.
>
> Certainly the original author of this code intended the MDIO
> _data_ rather than the _status_ register to be polled.
>
> Otherwise, why in the world have two functions which are in
> every other regard identical?

[ Removed Shaohui.Xie@nxp.com email from thread ; seems email addr no
longer valid ].

I should have added an RFC tag.
Thing is, we just use this driver, so, I can't offer much input here.

I was debugging [a while ago] some other issue related to this and
stumbled over this.
I haven't seem any obvious issues yet, to suggest one thing or or the
other [regarding polling status or data registers].

I would have liked some input from some NXP/Freescale people on this email list.
Or maybe I could forward this to more people that contribute the NXP eco-system.

If you have any suggestions, please advise and I'll adapt.

Thanks
Alex

>
> commit 26eee0210ad72a29eb4a70b34320bda266f91a0d
> Author: Shaohui Xie <Shaohui.Xie@freescale.com>
> Date:   Mon Mar 16 18:55:50 2015 +0800
>
>     net/fsl: fix a bug in xgmac_mdio
>
>     There is a bug in xgmac_wait_until_done() which mdio_stat should be used
>     instead of mdio_data when checking if busy bit is cleared.
>
>     Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
> index 3a83bc2..5f691f2 100644
> --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> @@ -79,7 +79,7 @@ static int xgmac_wait_until_done(struct device *dev,
>
>         /* Wait till the MDIO write is complete */
>         timeout = TIMEOUT;
> -       while ((ioread32be(&regs->mdio_data) & MDIO_DATA_BSY) && timeout) {
> +       while ((ioread32be(&regs->mdio_stat) & MDIO_STAT_BSY) && timeout) {
>                 cpu_relax();
>                 timeout--;
>         }
