From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net] i40e: proper update of the
 page_offset field
Date: Sun, 14 May 2017 17:31:55 -0700
Message-ID: <CAKgT0UdvyF5UJG9y0hWS3_JsjRTotHUEgK1bvOSiHWDSpMGggA@mail.gmail.com>
References: <20170514175649.31616-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>
To: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35980 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752784AbdEOAb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 20:31:57 -0400
Received: by mail-it0-f67.google.com with SMTP id z15so9113858ite.3
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 17:31:56 -0700 (PDT)
In-Reply-To: <20170514175649.31616-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 14, 2017 at 10:56 AM, Bj=C3=B6rn T=C3=B6pel <bjorn.topel@gmail.=
com> wrote:
> From: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>
>
> In f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
> i40e_build_skb updates the page_offset field with an incorrect offset,
> which can lead to data corruption. This patch updates page_offset
> correctly.
>
> Note that the bug only appears on architectures where PAGE_SIZE is
> 8192 or larger.
>
> Fixes: f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
> Signed-off-by: Bj=C3=B6rn T=C3=B6pel <bjorn.topel@intel.com>

Minor nit. I think i40evf has the same issue and requires the same
fix. Can you add that to this patch and resubmit? Otherwise this fix
looks good to me.

> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/et=
hernet/intel/i40e/i40e_txrx.c
> index 29321a6167a6..cd894f4023b1 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -1854,7 +1854,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_r=
ing *rx_ring,
>  #if (PAGE_SIZE < 8192)
>         unsigned int truesize =3D i40e_rx_pg_size(rx_ring) / 2;
>  #else
> -       unsigned int truesize =3D SKB_DATA_ALIGN(size);
> +       unsigned int truesize =3D SKB_DATA_ALIGN(sizeof(struct skb_shared=
_info)) +
> +                               SKB_DATA_ALIGN(I40E_SKB_PAD + size);
>  #endif
>         struct sk_buff *skb;
>
> --
> 2.11.0
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
