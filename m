From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: add ethtool support for set and
 get of settings
Date: Mon, 29 Feb 2016 17:50:40 -0500 (EST)
Message-ID: <20160229.175040.1966545191136367460.davem@davemloft.net>
References: <1456442648-13941-1-git-send-email-sixiao@microsoft.com>
	<20160229.170910.1568620456454101151.davem@davemloft.net>
	<1456785278.3098.146.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sixiao@microsoft.com, kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbcB2Wum convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 17:50:42 -0500
In-Reply-To: <1456785278.3098.146.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 29 Feb 2016 22:34:38 +0000

> On Mon, 2016-02-29 at 17:09 -0500, David Miller wrote:
>> From: Simon Xiao <sixiao@microsoft.com>
>> Date: Thu, 25 Feb 2016 15:24:08 -0800
>>=20
>> > This patch allows the user to set and retrieve speed and duplex of=
 the
>> > hv_netvsc device via ethtool.
>> >=A0
>> > Example:
>> > $ ethtool eth0
>> > Settings for eth0:
>> > ...
>> >=A0=A0=A0=A0 Speed: Unknown!
>> >=A0=A0=A0=A0 Duplex: Unknown! (255)
>> > ...
>> > $ ethtool -s eth0 speed 1000 duplex full
>> > $ ethtool eth0
>> > Settings for eth0:
>> > ...
>> >=A0=A0=A0=A0 Speed: 1000Mb/s
>> >=A0=A0=A0=A0 Duplex: Full
>> > ...
>> >=A0
>> > This is based on patches by Roopa Prabhu and Nikolay Aleksandrov.
>> >=A0
>> > Signed-off-by: Simon Xiao <sixiao@microsoft.com>
>>=20
>> Applied, thanks.
>=20
> I missed this due to flu, but now I look at it - I don't see the poin=
t.
> Link speed isn't meaingful for a memory-based transport, so "unknown"
> is correct. =A0The link is effectively full duplex though.
>=20
> If the issue is that ethtool is a bit shouty about unknowns, let's
> consider changing that in ethtool, not teaching drivers to lie.

The issue is that certain bonding modes do not work properly without
a speed being reported by a device.

We're doing this for other "virtual" devices already thanks to changes
that went in last week, so there is precedence.
