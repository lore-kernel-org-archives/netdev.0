From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: addrconf: use stable address generator for
 ARPHRD_NONE
Date: Thu, 17 Dec 2015 23:04:56 +0100
Message-ID: <56733188.8030205@stressinduktion.org>
References: <1450280678-4730-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59392 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932828AbbLQWE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:04:59 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id E3E3120398
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 17:04:58 -0500 (EST)
In-Reply-To: <1450280678-4730-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.12.2015 16:44, Bj=C3=B8rn Mork wrote:
> Add a new address generator mode, using the stable address generator
> with an automatically generated secret. This is intended as a default
> address generator mode for device types with no EUI64 implementation.
> The new generator is used for ARPHRD_NONE interfaces initially, addin=
g
> default IPv6 autoconf support to e.g. tun interfaces.
>=20
> If the addrgenmode is set to 'random', either by default or manually,
> and no stable secret is available, then a random secret is used as
> input for the stable-privacy address generator.  The secret can be
> read and modified like manually configured secrets, using the proc
> interface.  Modifying the secret will change the addrgen mode to
> 'stable-privacy' to indicate that it operates on a known secret.
>=20
> Existing behaviour of the 'stable-privacy' mode is kept unchanged. If
> a known secret is available when the device is created, then the mode
> will default to 'stable-privacy' as before.  The mode can be manually
> set to 'random' but it will behave exactly like 'stable-privacy' in
> this case. The secret will not change.
>=20
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miracleli=
nux.com>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> Changes since RFC:
>  - use IN6_ADDR_GEN_MODE_RANDOM as requested
>  - set the device type specific default in addrconf_dev_config() inst=
ead
>    of ipv6_add_dev() to catch device type changes
>=20
> I guess an explanation is needed for the last change: My primary
> use case for this is the raw-ip support recently added to the qmi_wwa=
n
> driver. This driver creates an ARPHRD_ETHER device which can be morph=
ed
> into an ARPHRD_NONE device. So at device creation time everything is
> fine and EUI64 is supported. But when the link is set up, the device
> type is change and EUI64 does not work. So I needed to override the
> default for ARPHRD_NONE at link up time.
>=20
> An alternative would be to keep the ipv6_add_dev() code and add devic=
e
> type change notifier code. That seemed messier to me. Besides, we
> already do type based address configuration decisions in
> addrconf_dev_config(), deciding whether autoconfiguration is availabl=
e
> or not.

Agreed to your statements above and I reviewed the patch. Also, I can't
see any bad side effects resulting in ARPHRD_NONE interfaces picking up
link local addresses in general.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
