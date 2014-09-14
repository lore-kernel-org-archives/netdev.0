From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] isdn: act2000: capi.c: Cleaning up unnecessary use of
 memset in conjunction with strncpy
Date: Sun, 14 Sep 2014 18:13:11 +0200
Message-ID: <CAFo99gYYpr6HUvG-+NXTrdPR6cWNeqsd-Tn4i7+o1y05X0ZyRw@mail.gmail.com>
References: <1410710471-14341-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:50966 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbaINQNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 12:13:33 -0400
Received: by mail-lb0-f176.google.com with SMTP id z11so3204140lbi.21
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 09:13:32 -0700 (PDT)
In-Reply-To: <1410710471-14341-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-09-14 18:01 GMT+02:00 Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se>:
> Using memset before strncpy just to ensure a trailing null
> character is an unnecessary double writing of a string
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/isdn/act2000/capi.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
> index 3f66ca2..1267739 100644
> --- a/drivers/isdn/act2000/capi.c
> +++ b/drivers/isdn/act2000/capi.c
> @@ -907,10 +907,10 @@ actcapi_dispatch(struct work_struct *work)
>                 case 0xff02:
>                         /* MANUFACTURER_IND */
>                         if (msg->msg.manuf_msg == 3) {
> -                               memset(tmp, 0, sizeof(tmp));
>                                 strncpy(tmp,
>                                         &msg->msg.manufacturer_ind_err.errstring,
> -                                       msg->hdr.len - 16);
> +                                       sizeof(tmp));
> +                               tmp[sizeof(tmp) - 1] = '\0';
>                                 if (msg->msg.manufacturer_ind_err.errcode)
>                                         printk(KERN_WARNING "act2000: %s\n", tmp);
>                                 else {
> @@ -1136,9 +1136,9 @@ actcapi_debug_msg(struct sk_buff *skb, int direction)
>                                msg->msg.manufacturer_ind_err.controller);
>                         printk(KERN_DEBUG " Code = 0x%08x\n",
>                                msg->msg.manufacturer_ind_err.errcode);
> -                       memset(tmp, 0, sizeof(tmp));
>                         strncpy(tmp, &msg->msg.manufacturer_ind_err.errstring,
> -                               msg->hdr.len - 16);
> +                               sizeof(tmp));
> +                       tmp[sizeof(tmp) - 1] = '\0';
>                         printk(KERN_DEBUG " Emsg = '%s'\n", tmp);
>                         break;
>                 }
> --
> 1.7.10.4
>

Hi

I'm sorry, this will not give the same effect :-(
Please, ignore this patch!

Kind regards
Rickard Strandqvist
