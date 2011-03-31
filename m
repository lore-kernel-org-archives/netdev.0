From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] net: ethtool support to configure number of RX rings
Date: Thu, 31 Mar 2011 00:55:28 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8BD6@MNEXMB2.qlogic.org>
References: <1301482774-2173-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:2208 "EHLO
	VA3EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932137Ab1CaFzl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 01:55:41 -0400
In-Reply-To: <1301482774-2173-1-git-send-email-amit.salecha@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> o Ethtool hook to configure number of RX rings.
> o Implementation is scalable to support configuring TX rings.
> o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
>   but it is tigtly coupled with RX flow hash configuration.
> o Patches for qlcnic and netxen_nic driver supporting this features
>   will follow soon.
>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  include/linux/ethtool.h |   20 ++++++++++++++++++++
>  net/core/ethtool.c      |   33 +++++++++++++++++++++++++++++++++
>  2 files changed, 53 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index aac3e2e..de0decd 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -226,6 +226,21 @@ struct ethtool_ringparam {
>       __u32   tx_pending;
>  };
>
> +/* for configuring number of RX ring */
> +struct ethtool_ring {
> +     __u32   cmd;    /* ETHTOOL_{G,S}RING */
> +
> +     /* Read only attributes.  These indicate the maximum number
> +      * of RX rings the driver will allow the user to set.
> +      */
> +     __u32   rx_max;
> +
> +     /* Values changeable by the user.  The valid values are
> +      * in the range 1 to the "*_max" counterpart above.
> +      */
> +     __u32   rx_pending;
> +};
> +

Current implementation can't scale to support TX rings. Because once structure is defined, that can't be changed.
As tools will have dependency on it.
If configuring tx rings need to be supported, I need to define Tx parameters in struct ethtool_ring now.
Currently qlcnic and netxen_nic driver doesn't have requirement to configure number of tx rings.
Should I define tx parameters in struct ethtool_ring ?

-Amit

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

