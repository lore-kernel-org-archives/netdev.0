From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net] i40e: proper update of the
 page_offset field
Date: Mon, 15 May 2017 06:13:22 +0200
Message-ID: <CAJ+HfNiiMbfwu8MPW+JixtsxSzxEb9n_UofSpuarFEeuWGhwDw@mail.gmail.com>
References: <20170514175649.31616-1-bjorn.topel@gmail.com> <CAKgT0UdvyF5UJG9y0hWS3_JsjRTotHUEgK1bvOSiHWDSpMGggA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33939 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932066AbdEOENY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 00:13:24 -0400
Received: by mail-wm0-f65.google.com with SMTP id d127so25251145wmf.1
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 21:13:24 -0700 (PDT)
In-Reply-To: <CAKgT0UdvyF5UJG9y0hWS3_JsjRTotHUEgK1bvOSiHWDSpMGggA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-15 2:31 GMT+02:00 Alexander Duyck <alexander.duyck@gmail.com>:
> On Sun, May 14, 2017 at 10:56 AM, Bj=C3=B6rn T=C3=B6pel <bjorn.topel@gmai=
l.com> wrote:
>> From: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>>
>> In f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
>> i40e_build_skb updates the page_offset field with an incorrect offset,
>> which can lead to data corruption. This patch updates page_offset
>> correctly.
>>
>> Note that the bug only appears on architectures where PAGE_SIZE is
>> 8192 or larger.
>>
>> Fixes: f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
>> Signed-off-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>
> Minor nit. I think i40evf has the same issue and requires the same
> fix. Can you add that to this patch and resubmit? Otherwise this fix
> looks good to me.

Good point. I'll send a v2, that addresses i40evf as well.

>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/e=
thernet/intel/i40e/i40e_txrx.c
>> index 29321a6167a6..cd894f4023b1 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>> @@ -1854,7 +1854,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_=
ring *rx_ring,
>>  #if (PAGE_SIZE < 8192)
>>         unsigned int truesize =3D i40e_rx_pg_size(rx_ring) / 2;
>>  #else
>> -       unsigned int truesize =3D SKB_DATA_ALIGN(size);
>> +       unsigned int truesize =3D SKB_DATA_ALIGN(sizeof(struct skb_share=
d_info)) +
>> +                               SKB_DATA_ALIGN(I40E_SKB_PAD + size);
>>  #endif
>>         struct sk_buff *skb;
>>
>> --
>> 2.11.0
>>
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@osuosl.org
>> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
