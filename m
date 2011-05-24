From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 21:37:13 +0200
Message-ID: <BANLkTinTJuKFyf80As81ouePBs=vFvQahg@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:34730 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061Ab1EXThe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 15:37:34 -0400
Received: by qyk7 with SMTP id 7so1689964qyk.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 12:37:33 -0700 (PDT)
In-Reply-To: <1306263162-2022-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/24 Mahesh Bandewar <maheshb@google.com>:
> Define macros to set/clear/test bits for feature set usage. This will=
 eliminate
> the direct use of these fields and enable future ease in managing the=
se fields.
>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> =A0include/linux/netdev_features.h | =A0137 +++++++++++++++++++++++++=
++++++++++++++
> =A0include/linux/netdevice.h =A0 =A0 =A0 | =A0 35 ++---------
> =A02 files changed, 142 insertions(+), 30 deletions(-)
> =A0create mode 100644 include/linux/netdev_features.h
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_f=
eatures.h
> new file mode 100644
> index 0000000..97bf8c4
> --- /dev/null
> +++ b/include/linux/netdev_features.h
> @@ -0,0 +1,137 @@
> +#ifndef =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
> +#define =A0 =A0 =A0 =A0_NETDEV_FEATURES_H
> +
> +/* Forward declarations */
> +struct net_device;
> +
> +typedef =A0 =A0 =A0 =A0unsigned long *nd_feature_t;
> +
> +/* Net device feature bits; if you change something,
> + * also update netdev_features_strings[] in ethtool.c */
> +enum netdev_features {
> + =A0 =A0 =A0 SG_BIT, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Scatter/gath=
er IO. */
[...]

Please split this change (introducing enum + converting NETIF_F_*
defines to use it). This part is a nice cleanup, but I think the
bitmap idea is still not worth the trouble until u64 runs out.

Best Regards,
Micha=B3 Miros=B3aw
