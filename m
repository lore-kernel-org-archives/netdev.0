From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv1] e1000e: Allow ethtool to enable/disable loopback.
Date: Wed, 11 May 2011 21:15:49 +0200
Message-ID: <BANLkTikXbL2arWSYW1aPV02C8dDdHTUG6Q@mail.gmail.com>
References: <1305140625-25888-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:40601 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab1EKTQK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 15:16:10 -0400
Received: by qyk7 with SMTP id 7so2501020qyk.19
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 12:16:09 -0700 (PDT)
In-Reply-To: <1305140625-25888-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/11 Mahesh Bandewar <maheshb@google.com>:
> This patch adds e1000_set_features() to handle loopback mode. When lo=
opback
> is enabled, it enables internal-MAC loopback.

Please wait for this driver's conversion to hw_features. One comment
below, though.

[...]
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
[...]
> +static int e1000_set_features(struct net_device *dev, u32 features)
> +{
> + =A0 =A0 =A0 u32 changed =3D dev->features ^ features;
> +
> + =A0 =A0 =A0 if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 e1000_set_loopback(dev, features);
> +
> + =A0 =A0 =A0 return 0;
> +}
[...]

If e1000_set_loopback() fails, this should set dev->features to passed
features (but keeping NETIF_F_LOOPBACK unchanged in dev->features) to
keep the state consistent.

Best Regards,
Micha=B3 Miros=B3aw
