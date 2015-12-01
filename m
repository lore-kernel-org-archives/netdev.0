From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Tue, 01 Dec 2015 12:22:22 +0100
Message-ID: <1448968942.3320842.454553905.2C5FBADD@webmail.messagingengine.com>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:57486 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752161AbbLALWX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 06:22:23 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id BA6CD20E70
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 06:22:22 -0500 (EST)
In-Reply-To: <1448884508-5235-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Nov 30, 2015, at 12:55, Bj=C3=B8rn Mork wrote:
> Generating a random ifid for devices with no L2 header
> at all, allowing such devices to take part in IPv6
> autoconfiguration. The tuntap driver is one example of
> a driver where such an ifid would be useful.
>=20
> Note that as there is no persistence, new addresses
> will be generated every time an interface is brought up:
>=20
>  # ip -6 addr show dev tun0
>  8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state
>  UNKNOWN qlen 500
>      inet6 fe80::eef2:111c:f270:92ba/64 scope link
>         valid_lft forever preferred_lft forever
>  # ip link set tun0 down
>  # ip link set tun0 up
>  # ip -6 addr show dev tun0
>  8: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 state
>  UNKNOWN qlen 500
>      inet6 fe80::eec0:48d0:6b52:8835/64 scope link
>         valid_lft forever preferred_lft forever
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> I'm planning raw-ip support for the qmi_wwan driver.  And
> the feedback from primary users (ModemManager++) is that
> a headerless netdev is preferred over a fake ethernet
> device. The current plan is to model this after 'tun'
> devices, using ARPHRD_NONE as type.
>=20
> But these devices will need an IPv6 link local address for
> full SLAAC support.  I am therefore wondering if an approach
> like this patch will be acceptable, or if I should look for
> some other solution?

I see no problem with the patch as it eases operating those devices. I
would also suggest storing the ifid in the inet6_dev so it does only
change during device creation and destruction. Otherwise I would
recommend to use stable privacy addresses to generate the link local
addresses. EUI-48 based LL creation should hopefully not be used anymor=
e
soon.

Thanks,
Hannes
