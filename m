From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: use ndo_change_rx_flags callback
Date: Tue, 16 Aug 2011 12:03:42 +0200
Message-ID: <CAHXqBFJL+y3TOj-OX4wXT-H1Z9R3EqJLnA64t5_ocCKLx6tPUQ@mail.gmail.com>
References: <1313487050-4048-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53611 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab1HPKEE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 06:04:04 -0400
Received: by qyk38 with SMTP id 38so1275355qyk.19
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2011 03:04:03 -0700 (PDT)
In-Reply-To: <1313487050-4048-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/16 Jiri Pirko <jpirko@redhat.com>:
> Benefit from use of ndo_change_rx_flags in handling change of promisc
> and allmulti. No need to store previous state locally.
[...]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 854aa8d..731763a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
[...]
> -static void bond_set_multicast_list(struct net_device *bond_dev)
> +static void bond_change_rx_flags(struct net_device *bond_dev, int ch=
ange)
>  {
[...]
> +       if (change & IFF_PROMISC)
> +               bond_set_promiscuity(bond,
> +                                    bond_dev->flags & IFF_ALLMULTI ?=
 1 : -1);

Typo: flags & IFF_PROMISC ?

Best Regards,
Micha=B3 Miros=B3aw
