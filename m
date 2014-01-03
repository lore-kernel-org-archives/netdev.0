From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Fri, 3 Jan 2014 07:30:41 +0100
Message-ID: <20140103063041.GJ22494@order.stressinduktion.org>
References: <1388728736.50849.YahooMailBasic@web125506.mail.ne1.yahoo.com> <1388729964.50446.YahooMailBasic@web125501.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36684 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaACGan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 01:30:43 -0500
Content-Disposition: inline
In-Reply-To: <1388729964.50446.YahooMailBasic@web125501.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 10:19:24PM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Fri, 1/3/14, Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com> wr=
ote:
>=20
> --------------------------------------------
>  On Thu, 1/2/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wr=
ote:
>  =20
> >> Ah, I guess you are hinting at the situation where you
> >> ping
> >> a pre-defined
> >> anycast address and expect back a unicast address for
> >> discovering the unicast
> >> address of a router e.g.? Ok, I see...
>  =20
> > Exact
>=20
> more:=20
> Some setup may use a ping to Subnet-Router anycast address and expect=
 a reply to discover a unicast address (not very secure, but ...).
>=20
> It is the reason why, I want to keep existing default.

Yep, with pre-defined anycast address I actually meant the subnet route=
r
anycast address. We currently don't need to deal with more than that on=
e:
https://www.iana.org/assignments/ipv6-anycast-addresses/ipv6-anycast-ad=
dresses.xhtml

As soon as this patch gets applied, we have to keep the knob stable
in its semantic.  So my proposal would be to change the knob to just
control the behaviour of ping replies and also change its name to refle=
ct
this.

Leave datagram sending with specific anycast address as source just ope=
n and
don't protect it with this knob. Would that be a plan?
