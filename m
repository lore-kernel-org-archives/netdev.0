From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] drivers/net: param for lapbether for specific ethernet
 device
Date: Wed, 19 Jun 2013 17:47:48 +0400
Message-ID: <51C1B684.6010700@cogentembedded.com>
References: <51C16A07.3070903@ntlworld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Moorby <steve.moorby@ntlworld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:35290 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756667Ab3FSNrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 09:47:46 -0400
Received: by mail-la0-f52.google.com with SMTP id fo12so4647593lab.39
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 06:47:44 -0700 (PDT)
In-Reply-To: <51C16A07.3070903@ntlworld.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-06-2013 12:21, Stephen Moorby wrote:

>  From 35607dd0607bca5322860703143c31cb04377764 Mon Sep 17 00:00:00 2001
> From: Stephen Moorby <steve.moorby@ntlworld.com>
> Date: Wed, 19 Jun 2013 08:22:51 +0100
> Subject: [PATCH 1/1] drivers/net: param for lapbether for specific ethernet
>   device

    No need for this header.

> The lapbether driver binds to the first ethernet device that comes up.
> This causes problems in hardware with multiple ethernet interfaces,
> potentially resulting in the LAPB traffic on the wrong interface.
> Have added a module parameter 'eth_dev' to specify the ethernet
> interface over which lapbether should operate.  The module behaves
> as before if no device is specified.
>
> Patch created on linux-next 18-Jun-2013.
> Tested on 2.6.32-45-generic.
>
> Signed-off-by: Stephen Moorby <steve.moorby@ntlworld.com>
> ---
>   drivers/net/wan/lapbether.c | 15 +++++++++++++--
>   1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
> index a33a46f..510fc4a 100644
> --- a/drivers/net/wan/lapbether.c
> +++ b/drivers/net/wan/lapbether.c
[...]
> @@ -381,8 +382,14 @@ static int lapbeth_device_event(struct
> notifier_block *this,

    Your patch is line-wrapped.

>       switch (event) {
>       case NETDEV_UP:
>           /* New ethernet device -> new LAPB interface     */
> -        if (lapbeth_get_x25_dev(dev) == NULL)
> -            lapbeth_new_device(dev);
> +        if (lapbeth_get_x25_dev(dev) == NULL) {
> +            if (NULL != eth_dev) {
> +                if (0 == strcmp(dev->name, eth_dev))
> +                    lapbeth_new_device(dev);
> +            } else {
> +                lapbeth_new_device(dev);
> +            }
> +        }

    It seems the patch is also white space damaged, i.e. tabs converted 
to spaces.

WBR, Sergei
