From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/5] vxlan: Make VXLAN default UDP port number
 available for others
Date: Mon, 10 Mar 2014 21:57:40 +0200
Message-ID: <CAJZOPZ+MFe2ev372L07uVvXs_wYnqAiZ3VMG4YteD2XmPWHoSQ@mail.gmail.com>
References: <1394470142-13992-1-git-send-email-shahed.shaikh@qlogic.com>
	<1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dept-HSGLinuxNICDev@qlogic.com
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65014 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbaCJT5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:57:41 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so7788479pab.33
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 12:57:40 -0700 (PDT)
In-Reply-To: <1394470142-13992-2-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 6:48 PM, Shahed Shaikh <shahed.shaikh@qlogic.com> wrote:
> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
>
> Although vxlan module has capability to notify udp ports to
> other interested net devices using .ndo_add_rx_vxlan_port and
> .ndo_del_rx_vxlan_port, there could be some devices which support
> vxlan offload but not interested in updating udp port numbers.
> This may be because some hardware do not support programming multiple
> udp ports and their drivers may decide to program only default udp port
> into adapter. So that adapter, at least, can do offloading for
> default udp port number.

Indeed, but the default port number can be unused while another port
is used. The ndo will be invoked only behalf
of an actual instancing of udp port for listener socket (==
destination port you want the hw to indentify), what's wrong
with support this ndo also for devices that supported limited (say
one) such port?


>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> ---
>  drivers/net/vxlan.c | 6 +-----
>  include/net/vxlan.h | 6 ++++++
>  2 files changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index eb59b14..ace758f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -71,11 +71,7 @@ struct vxlanhdr {
>         __be32 vx_vni;
>  };
>
> -/* UDP port for VXLAN traffic.
> - * The IANA assigned port is 4789, but the Linux default is 8472
> - * for compatibility with early adopters.
> - */
> -static unsigned short vxlan_port __read_mostly = 8472;
> +static unsigned short vxlan_port __read_mostly = VXLAN_DEFAULT_PORT;
>  module_param_named(udp_port, vxlan_port, ushort, 0444);
>  MODULE_PARM_DESC(udp_port, "Destination UDP port");
>
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index 5deef1a..4c16629 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -8,6 +8,12 @@
>  #define VNI_HASH_BITS  10
>  #define VNI_HASH_SIZE  (1<<VNI_HASH_BITS)
>
> +/* UDP port for VXLAN traffic.
> + * The IANA assigned port is 4789, but the Linux default is 8472
> + * for compatibility with early adopters.
> + */
> +#define VXLAN_DEFAULT_PORT 8472
> +
>  struct vxlan_sock;
>  typedef void (vxlan_rcv_t)(struct vxlan_sock *vh, struct sk_buff *skb, __be32 key);
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
