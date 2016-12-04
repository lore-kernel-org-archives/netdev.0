From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] isdn: hisax: set error code on failure
Date: Sun, 4 Dec 2016 13:14:18 +0300
Message-ID: <f40332a1-8fc1-96e1-5592-95e8509c68a3@cogentembedded.com>
References: <1480828511-4251-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201603@163.com>,
        Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35378 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbcLDKOX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 05:14:23 -0500
Received: by mail-wm0-f45.google.com with SMTP id a197so55531934wmd.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 02:14:22 -0800 (PST)
In-Reply-To: <1480828511-4251-1-git-send-email-bianpan201603@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/4/2016 8:15 AM, Pan Bian wrote:

> From: Pan Bian <bianpan2016@163.com>
>
> In function hfc4s8s_probe(), the value of return variable err should be
> negative on failures. However, when the call to request_region() returns
> NULL, the value of err is 0. This patch fixes the bug, assiging
> "-ENOMEM" to err on the path that request_region() fails.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188931
>
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  drivers/isdn/hisax/hfc4s8s_l1.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
> index 9600cd7..3172cee 100644
> --- a/drivers/isdn/hisax/hfc4s8s_l1.c
> +++ b/drivers/isdn/hisax/hfc4s8s_l1.c
> @@ -1499,6 +1499,7 @@ struct hfc4s8s_l1 {
>  		printk(KERN_INFO
>  		       "HFC-4S/8S: failed to request address space at 0x%04x\n",
>  		       hw->iobase);
> +		err = -ENOMEM;

    -EBUSY fits request_region() better.

[..]

MBR, Sergei
