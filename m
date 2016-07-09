From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: addrconf: fix Juniper SSL VPN client regression
Date: Sun, 10 Jul 2016 00:19:32 +0200
Message-ID: <1468102772.3805579.661647841.59799999@webmail.messagingengine.com>
References: <1468098791-20420-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Jonas Lippuner <jonas@lippuner.ca>,
	=?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40397 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756855AbcGIWTe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 18:19:34 -0400
In-Reply-To: <1468098791-20420-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

On Sat, Jul 9, 2016, at 23:13, Bj=C3=B8rn Mork wrote:
> The Juniper SSL VPN client use a "tun" interface and seems to
> be picky about visible changes.to it. Commit cc9da6cc4f56
> ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
> made such interfaces get an auto-generated IPv6 link local address
> by default, similar to most other interface types. This made the
> Juniper SSL VPN client fail for unknown reasons.
>=20
> Fixing this regression by effectively reverting the behaviour to
> what we had before, while keeping the new "addrgenmode random"
> feature.

I wonder if we can simply add a flag, something like
IFF_SUPPRESS_AUTO_IPV6_LL, to net_device->priv_flags and use that. So w=
e
can keep behavior for qmi, vxlan-gpe and gre. tun is the only device
that is really user space facing, so maybe we just limit it to this?

Thanks,
Hannes
