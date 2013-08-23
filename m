From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 2/2] ipv6: Add support for IPsec virtual tunnel
 interfaces
Date: Fri, 23 Aug 2013 08:12:15 +0200
Message-ID: <20130823061214.GG26773@secunet.com>
References: <20130819062623.GN26773@secunet.com>
 <20130819062730.GP26773@secunet.com>
 <5215C1F4.9030609@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50598 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754513Ab3HWGMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 02:12:17 -0400
Content-Disposition: inline
In-Reply-To: <5215C1F4.9030609@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 03:47:00PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B408=E6=9C=8819=E6=97=A5 14:27, Steffen Klassert wrote:
> >+
> >+	skb_dst_drop(skb);
> >+	skb_dst_set_noref(skb, dst);
> >+
> >+	ip6tunnel_xmit(skb, dev);
> >+	if (ndst)
> >+		ip6_tnl_dst_store(t, ndst);
> >+	return 0;
> >+tx_err_link_failure:
> >+	stats->tx_carrier_errors++;
> >+	dst_link_failure(skb);
> >+tx_err_dst_release:
>=20
> Maybe it's necessary to count stats->tx_errors as well.

We count it directly after an error return of this function.
