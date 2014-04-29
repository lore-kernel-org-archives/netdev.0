From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Tue, 29 Apr 2014 08:28:09 -0700
Message-ID: <CA+mtBx9eC5rVuD3GFSeCxvCkm_0W=_VOi8VJV8CofdpHyCpdGA@mail.gmail.com>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:53356 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaD2Pg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 11:36:26 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so445929iec.39
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 08:36:25 -0700 (PDT)
In-Reply-To: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Since SCTP is using a variant of CRC32 in a fairly generic manner,
would it be possible to provide a general API to offload it like in
NETIF_F_HW_CSUM? A strong CRC offloaded might be useful for other
protocols.

Thanks,
Tom


On Mon, Apr 28, 2014 at 12:52 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> Some HW can offload encapsulated SCTP checksums.  Advertise the capability
> for such cases.
>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/vxlan.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1dfee9a..988208f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_device *dev)
>         dev->features   |= NETIF_F_SG | NETIF_F_HW_CSUM;
>         dev->features   |= NETIF_F_RXCSUM;
>         dev->features   |= NETIF_F_GSO_SOFTWARE;
> +       dev->features   |= NETIF_F_SCTP_CSUM;
>
>         dev->vlan_features = dev->features;
>         dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
