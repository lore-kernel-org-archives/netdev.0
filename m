From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH] stmmac: Remove unbalanced clk_disable call
Date: Tue, 20 May 2014 18:59:01 +0800
Message-ID: <CAGb2v65BLk2zOQKvhsuNsdjkhRA6UduaVeozXWr2PyWb+SkYFA@mail.gmail.com>
References: <1400578698-6407-1-git-send-email-hdegoede@redhat.com> <537B29A4.1010100@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hans de Goede <hdegoede@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:52926 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaETK7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 06:59:22 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf12so350850vcb.15
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 03:59:22 -0700 (PDT)
In-Reply-To: <537B29A4.1010100@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 6:08 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 5/20/2014 11:38 AM, Hans de Goede wrote:
>>
>> The stmmac_open call was calling clk_disable_unprepare on phy init
>> failure, but it never calls clk_prepare_enable, this causes
>> a WARN_ON in the clk framework to trigger if for some reason phy init
>> fails.
>>
>> Signed-off-by: Hans de Goede <hdegoede@redhat.com>
>
>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This looks like left-overs from

    62866e9 net: stmmac: Enable stmmac main clock when probing hardware

Acked-by: Chen-Yu Tsai <wens@csie.org>

>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
>>   1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index d940034..0f4841d 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -1704,7 +1704,7 @@ static int stmmac_open(struct net_device *dev)
>>                 if (ret) {
>>                         pr_err("%s: Cannot attach to PHY (error: %d)\n",
>>                                __func__, ret);
>> -                       goto phy_error;
>> +                       return ret;
>>                 }
>>         }
>>
>> @@ -1779,8 +1779,6 @@ init_error:
>>   dma_desc_error:
>>         if (priv->phydev)
>>                 phy_disconnect(priv->phydev);
>> -phy_error:
>> -       clk_disable_unprepare(priv->stmmac_clk);
>>
>>         return ret;
>>   }
>>
>
