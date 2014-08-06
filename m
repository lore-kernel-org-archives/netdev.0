From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: IPv6 over IEEE 802.15.4 aka 6LoWPAN - Neighbor discovery issue
Date: Wed, 6 Aug 2014 12:36:44 +0200
Message-ID: <20140806103642.GA32302@omega>
References: <20140805121516.GB14196@omega>
 <53E1797C.8000207@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-wpan@vger.kernel.org
To: YOSHIFUJI =?utf-8?B?SGlkZWFraS/lkInol6Toi7HmmI4=?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:44335 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755296AbaHFKgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 06:36:53 -0400
Content-Disposition: inline
In-Reply-To: <53E1797C.8000207@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

thanks for your reply.

On Wed, Aug 06, 2014 at 09:40:28AM +0900, YOSHIFUJI Hideaki/=E5=90=89=E8=
=97=A4=E8=8B=B1=E6=98=8E wrote:
> Hi,
>=20
> Alexander Aring wrote:
> >There exist no mapping between extended and short addresses. The glo=
bal problem
> >that the neighbor discovery cache handle the address length with a s=
tatic addr_len
> >value from net_device, this value should not be changed during runti=
me.
> >
> >
> >To handle 6LoWPAN over IEEE 802.15.4 correctly we need to indicate t=
hat the neighbor
> >discovery stores an extended or short address.
> :
> >My idea:
> >
> >Let addr_len to extended_address_length + 1. In the last byte we hav=
e a bit which
> >indicate that is it a short address. If this bit isn't set we have a=
n extended
> >address.
> >
> >If we do that, we need some conversions about generating the ICMPv6 =
messages according
> >to [1]. We can solve that with some hooks in net/ipv6/ndisc.c like t=
he ndisc_mc_map
> >function for mapping mac multicast addresses.
> >
> >Another idea to avoid hooks in net/ipv6/ndisc.c  is to parse and reb=
uild the ICMPv6
> >header while replacing IPv6 with the 6LoWPAN header.
>=20
> Please avoid magling icmpv6/ipv6 bits as much as possible.
>=20

Okay.

> >Please I need help and I need a solution which is also acceptable fo=
r mainline.
>=20
> We can have L2-specific private data per NCE, and 6lowpan uses ARPHRD=
_IEEE802154.

=46irst I need to clarify that we have two 6LoWPAN implementations, one
for 802.15.4 and the other one for bluetooth. Each have some generic
code inside of net/6lowpan.

What we need for this neighbor discovery issue is 802.15.4 specific onl=
y.
I think bluetooth 6LoWPAN can deal with the normal behaviour.

That a 6lowpan device for ieee802.15.4 use ARPHRD_IEEE802154 is wrong,
we need something like ARPHRD_IEEE802154_6LOWPAN, but this is another p=
roblem.

I will introduce it, currently this is most wrong because wireshark
thinks there are 802.15.4 frames but on this interface should only plai=
n
IPv6 and upper layers visible. But this is out of scope of this issue.
I can't also use ARPHRD_6LOWPAN otherwise bluetooth will do these
802.15.4 specific things in neighbor discovery.

> Please consider using it for L2 private data, if you need L2-speicic =
extra
> information per NCE.

okay, I will try to implement something which allow this and make
_small_ changes according ARPHRD_... during runtime. I will send it as =
RFC
and we can discuss about that.

I will try to have a less of evaluating dev->type much as possible.

- Alex
