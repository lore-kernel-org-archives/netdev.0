From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Sun, 21 Jul 2013 23:26:32 +0300
Message-ID: <CAJZOPZJiL4hJV4eKKsZrLseJF_sSRjYVsstgT+NLsoeCXWKh_g@mail.gmail.com>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
	<1374342834-10814-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:33207 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab3GUU0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 16:26:33 -0400
Received: by mail-qc0-f181.google.com with SMTP id u12so3254492qcx.12
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 13:26:32 -0700 (PDT)
In-Reply-To: <1374342834-10814-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo.


Do you mean virtual function literally?  that is in the PCI IOV aspect?


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
> +
>  /*
>   * This structure defines the management hooks for network devices.
>   * The following hooks can be defined; unless noted otherwise, they are
> @@ -932,6 +942,12 @@ struct netdev_fcoe_hbainfo {
>   *     that determine carrier state from physical hardware properties (eg
>   *     network cables) or protocol-dependent mechanisms (eg
>   *     USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
> + *
> + * int (*ndo_get_phys_port_id)(struct net_device *dev,
> + *                            struct netdev_phys_port_id *ppid);
> + *     Called to get ID of physical port of this device. If driver does
> + *     not implement this, it is assumed that the hw is not able to have
> + *     multiple net devices on single physical port.
>   */

I am not sure to understand what is assumed here and why it it mandated.
