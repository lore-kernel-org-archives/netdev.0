From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 14:21:42 -0500 (EST)
Message-ID: <20130228.142142.242861205295035084.davem@davemloft.net>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de>
	<CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hauke@hauke-m.de, netdev@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab3B1TVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 14:21:44 -0500
In-Reply-To: <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
Date: Thu, 28 Feb 2013 18:57:03 +0100

> 2013/2/28 Hauke Mehrtens <hauke@hauke-m.de>:
>> Do not include the frame check sequence when adding the skb to
>> netif_receive_skb(). This causes problems when this interface was
>> bridged to a wifi ap and a big package should be forwarded from this
>> Ethernet driver through a bride to the wifi client.
>=20
> Is this a real fix?
>=20
> Don't get me wrong, but it sounds a little like a workaround for some
> issue in another network layer ;)

=46CS should never be included in the SKB unless a specific debugging
configuration knob has enabled it.

Having the FCS there will screw up things like device provided partial
checksums (CHECKSUM_PARTIAL), which operate over the entire contents
of the packet starting at a particular offset, so if the FCS is there
we'll include it.

This change is therefore about as correct as can possibly be.
