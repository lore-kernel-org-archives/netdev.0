From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Sun, 21 Jul 2013 14:10:41 +0300
Message-ID: <CAJZOPZJaKbMhtN4JSi6ScaRtwUNMK69trCccsdZvA7=57cDknQ@mail.gmail.com>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
	<1374342834-10814-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f53.google.com ([209.85.128.53]:36271 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab3GULKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 07:10:41 -0400
Received: by mail-qe0-f53.google.com with SMTP id f6so294994qej.40
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 04:10:41 -0700 (PDT)
In-Reply-To: <1374342834-10814-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/netdevice.h | 20 ++++++++++++++++++++
>  net/core/dev.c            | 18 ++++++++++++++++++
>  2 files changed, 38 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0741a1e..726dec2 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
>  };
>  #endif
>
> +#define MAX_PHYS_PORT_ID_LEN 32
> +
> +/* This structure holds a unique identifier to identify the
> + * physical port used by a netdevice.
> + */
> +struct netdev_phys_port_id {
> +       unsigned char id[MAX_PHYS_PORT_ID_LEN];
> +       unsigned char id_len;
> +};


So an integer (four bytes?) is OK here? does it need to be in certain
byte order?
