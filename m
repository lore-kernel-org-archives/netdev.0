From: Wan ZongShun <mcuos.com@gmail.com>
Subject: Re: [PATCH] Stmmac: fix a bug when clk_csr == 0x0
Date: Wed, 9 Oct 2013 23:02:59 +0800
Message-ID: <CAKT61h8ZLQRUsD99vOYyK8jj0o_SHhA+PN4MoPA5SS9V+eit5g@mail.gmail.com>
References: <CAKT61h8mcj1Gvp1i8xkM_NS2+fv1WhPtCQaFq7mi=i=JUqT4Uw@mail.gmail.com>
 <52556BA2.1080004@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:63161 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab3JIPDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 11:03:20 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so1022270pbc.12
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 08:03:19 -0700 (PDT)
In-Reply-To: <52556BA2.1080004@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/9 Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
> hello
>
>
> On 10/9/2013 4:37 AM, Wan ZongShun wrote:
>>
>> Hi Giuseppe,
>>
>> According to spec, if csr clock freq is 60-100Mhz, we have to set CR=
[5:2]
>> =3D 0000
>> but when I set the 'plat_dat.clk_csr =3D 0',acctually, this value is=
 not
>> used
>> since the driver code judge 'if (!priv->plat->clk_csr)' then go to d=
ynamic
>> tune
>> the MDC clock. So I add other judge condition.
>
>
> yes, and true in case of 60-100Mhz... I don't know if this was actual=
ly
> tested on SPEAr long time ago.
>

Hmmm, I am using other GBE chip based on synopsis IP, so I am testing
it on other platform.

> Pls document the new platform field in the stmmac.txt or find a way
> to reuse the clk_csr (maybe not the case)

Do you mean I need submit the other patch to add some comments for
this new field=EF=BC=9F
I can not find better way to fix this issue and make it more
compatible to another platform.

Wan.

>
> peppe
>
>
>>
>> Signed-off-by: Wan Zongshun <mcuos.com@gmail.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>>   include/linux/stmmac.h                            | 1 +
>>   2 files changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 8d4ccd3..a849092c 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2741,7 +2741,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct
>> device *device,
>>        * set the MDC clock dynamically according to the csr actual
>>        * clock input.
>>        */
>> -    if (!priv->plat->clk_csr)
>> +    if (priv->plat->dynamic_mdc_clk_en)
>>           stmmac_clk_csr_set(priv);
>>       else
>>           priv->clk_csr =3D priv->plat->clk_csr;
>> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
>> index bb5deb0..e2552ce 100644
>> --- a/include/linux/stmmac.h
>> +++ b/include/linux/stmmac.h
>> @@ -101,6 +101,7 @@ struct plat_stmmacenet_data {
>>       struct stmmac_mdio_bus_data *mdio_bus_data;
>>       struct stmmac_dma_cfg *dma_cfg;
>>       int clk_csr;
>> +    int dynamic_mdc_clk_en;
>>       int has_gmac;
>>       int enh_desc;
>>       int tx_coe;
>>
>



--=20
Wan ZongShun.
www.mcuos.com
