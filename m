From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 3 Jun 2008 10:21:44 -0700
Message-ID: <20080603102144.571df55b@extreme>
References: <20080602165249.52a467dc@extreme>
	<20080602165347.5662f602@extreme>
	<20080604.011717.77875207.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35186 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbYFCRVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:21:45 -0400
In-Reply-To: <20080604.011717.77875207.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Jun 2008 01:17:17 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshfuji@linu=
x-ipv6.org> wrote:

> In article <20080602165347.5662f602@extreme> (at Mon, 2 Jun 2008 16:5=
3:47 -0700), Stephen Hemminger <shemminger@vyatta.com> says:
>=20
> > Similar to previous change for IPV4. Allow configuration option to =
remove
> > addresses from FIB when carrier is lost.
> >=20
> > This patch also makes IPV6 ignore changes to carrier state when dev=
ice
> > is admin down state. This prevents address configuration from start=
ing
> > up on a buggy device driver that signals carrier changes when offli=
ne.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Well, we need to be careful here.
> IMHO we should not remove addresses (especially link-local address
> based on MAC, or manually assigned addresses, maybe).
> We might want to do Optimistic DAD here.
>=20
> --yoshfuji

The patch just makes carrier_off respond the same as doing 'ip link set=
 dev eth0 down'
(or ifconfig eth0 down). A router needs to be able to re-route when lin=
k fails.
