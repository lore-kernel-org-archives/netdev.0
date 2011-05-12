From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 07:59:45 +0200
Message-ID: <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57334 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198Ab1ELGAH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 02:00:07 -0400
In-Reply-To: <20110512054415.435611676@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/12  <frank.blaschka@de.ibm.com>:
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>
> Set rx csum default to hw checksumming again.
> Remove sysfs interface for rx csum (checksumming) and TSO (large_send=
).
> With the new hw_features it does not work to keep the old sysfs
> interface in parallel. Convert options.checksum_type to new hw_featur=
es.
[...]
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* hw may have cha=
nged during offline or recovery */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!qeth_is_suppo=
rted(card, IPA_INBOUND_CHECKSUM)) {
[...]

This check should go to ndo_fix_features callback. If it fails then
just return features &~NETIF_F_RXCSUM from there ...

> +update_feature:
> + =C2=A0 =C2=A0 =C2=A0 rtnl_lock();
> + =C2=A0 =C2=A0 =C2=A0 card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
> + =C2=A0 =C2=A0 =C2=A0 card->dev->features &=3D ~NETIF_F_RXCSUM;
> + =C2=A0 =C2=A0 =C2=A0 netdev_update_features(card->dev);
> + =C2=A0 =C2=A0 =C2=A0 rtnl_unlock();

=2E.. and then this should be just:
rtnl_lock();
netdev_update_features(card->dev);
rtnl_unlock();

BTW, How is the recovery process protected from interface removal if
it's not run under rtnl_lock?

Best Regards,
Micha=C5=82 Miros=C5=82aw
