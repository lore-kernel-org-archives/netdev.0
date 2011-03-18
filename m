From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] net: drop NETIF_F_GSO from hw_features without NETIF_F_SG
Date: Fri, 18 Mar 2011 21:43:23 +0100
Message-ID: <AANLkTim1_+GdURWxk=+N+5xCFTF1L27BD=+Uu+BY4jWF@mail.gmail.com>
References: <20110318195030.GA22350@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:34289 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756932Ab1CRUno convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 16:43:44 -0400
Received: by qyk7 with SMTP id 7so1134695qyk.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 13:43:43 -0700 (PDT)
In-Reply-To: <20110318195030.GA22350@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/18 Roger Luethi <rl@hellgate.ch>:
> register_netdevice() removes NETIF_F_GSO from dev->features and
> dev->wanted_features for hardware without NETIF_F_SG to "avoid warnin=
g from
> netdev_fix_features()".
>
> However, as the flag remains set in dev->hw_features, users trying to
> enable GSO via ethtool will still end up with NETIF_F_GSO stuck in
> wanted_features, resulting in a warning every time they try to change=
 any
> feature (until they use ethtool to "disable" GSO):

That's expected, as it allows the user to debug why his request didn't
work as expected. I think that those messages should get demoted to
DEBUG if that's too noisy. The network core imposed conditions could
be explained in Documentation/ or ethtool manpage instead.

Best Regards,
Micha=B3 Miros=B3aw
