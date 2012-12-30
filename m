From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next] team: implement carrier change
Date: Sun, 30 Dec 2012 14:03:28 +0100
Message-ID: <CAHXqBFKtm6y3V-OepX9NnDP1GT28J=tPRmEtmR68wACPT9Pq8g@mail.gmail.com>
References: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Flavio Leitner <fbl@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:61398 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab2L3NI7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 08:08:59 -0500
Received: by mail-ob0-f175.google.com with SMTP id vb8so10771343obc.6
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 05:08:58 -0800 (PST)
In-Reply-To: <1356831061-1483-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/30 Flavio Leitner <fbl@redhat.com>:
> The user space teamd daemon may need to control the
> master's carrier state depending on the selected mode.
[...]
> +static int team_change_carrier(struct net_device *dev, bool new_carr=
ier)
> +{
> +       if (new_carrier)
> +               netif_carrier_on(dev);
> +       else
> +               netif_carrier_off(dev);
> +       return 0;
> +}
> +
[...]
> +       .ndo_change_carrier     =3D team_change_carrier,

I wonder what else you might put in the .ndo_change_carrier
implementation? It's already the same for dummy device and tunnels
would get more copies. Maybe it would be enough to allocate a bit in
netdev->priv_flags and use that in dev_change_carrier() instead?

Best Regards,
Micha=C5=82 Miros=C5=82aw
