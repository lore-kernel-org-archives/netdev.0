From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: [PATCH V3 29/29] ethernet: use parity8 in broadcom/tg3.c
Date: Fri, 22 Apr 2016 10:16:24 +0530
Message-ID: <CAMet4B7K0N3cq24riNO1uC6QaOCx2FFRV77YoQ9QFV1wFq-jfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: zengzhaoxiu@163.com, Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:33929 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbcDVEq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 00:46:26 -0400
Received: by mail-lf0-f49.google.com with SMTP id j11so72521425lfb.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 21:46:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 8:42 AM, <zengzhaoxiu@163.com> wrote:
>
> From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
>
> Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
Looks good to me.
Acked-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 3010080..802a429 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -12939,11 +12939,7 @@ static int tg3_test_nvram(struct tg3 *tp)
>
>                 err = -EIO;
>                 for (i = 0; i < NVRAM_SELFBOOT_DATA_SIZE; i++) {
> -                       u8 hw8 = hweight8(data[i]);
> -
> -                       if ((hw8 & 0x1) && parity[i])
> -                               goto out;
> -                       else if (!(hw8 & 0x1) && !parity[i])
> +                       if (parity8(data[i]) == !!parity[i])
>                                 goto out;
>                 }
>                 err = 0;
> --
> 2.5.0
>
>
