From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH v3 net-next 1/2] ipv4: L3 hash-based multipath
Date: Wed, 23 Sep 2015 21:22:20 +0200
Message-ID: <20150923212220.6025d4e2@pch.odense.ordbogen.com>
References: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
	<1442348993-3023-2-git-send-email-pch@ordbogen.com>
	<560035BD.6090908@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:43520 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbbIWTWW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 15:22:22 -0400
In-Reply-To: <560035BD.6090908@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Sep 2015 10:52:13 -0600
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 9/15/15 2:29 PM, Peter N=C3=B8rlund wrote:
> > @@ -1094,8 +1142,15 @@ struct fib_info *fib_create_info(struct
> > fib_config *cfg)
> >
> >   	change_nexthops(fi) {
> >   		fib_info_update_nh_saddr(net, nexthop_nh);
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +		fi->fib_weight +=3D nexthop_nh->nh_weight;
> > +#endif
> >   	} endfor_nexthops(fi)
> >
> > +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> > +	fib_rebalance(fi);
> > +#endif
>=20
> The ifdefs everywhere make this harder to read. Just have a second=20
> definition above for fib_rebalance(fi) when CONFIG_IP_ROUTE_MULTIPATH
> is not defined.
>=20
> Similarly an inlined macro of fi->fib_weight that compiles out if=20
> CONFIG_IP_ROUTE_MULTIPATH is not defined.
>=20
> David

Okay, will do.

Regards,
 Peter N=C3=B8rlund
