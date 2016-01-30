From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Sat, 30 Jan 2016 09:25:35 -0800
Message-ID: <1454174735.7329.20.camel@perches.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
	 <1454159878-20706-3-git-send-email-tanure@linux.com>
	 <20160130134550.GA5613@macbook.localdomain>
	 <CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lucas Tanure <tanure@linux.com>, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:43573 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932215AbcA3RZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 12:25:39 -0500
In-Reply-To: <CAJX_Q+18D3omXJRy-2CEieqhAXCwpFwwt=JiRWkozPqs4cC96g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-01-30 at 12:05 -0200, Lucas Tanure wrote:
> On Sat, Jan 30, 2016 at 11:45 AM, Patrick McHardy <kaber@trash.net> w=
rote:
> > On 30.01, Lucas Tanure wrote:
> > > As suggested by checkpatch.pl:
> > > CHECK: Prefer kernel type 'uX' over 'uintX_t'
> >=20
> > You might have noticed we have literally hundreds of them spread ov=
er 100
> > files in the netfilter code. We'll gradually change them when the c=
ode is
> > touched anyways.
> >=20
> > > =A0net/ipv4/netfilter/ip_tables.c | 5 ++---
> > > =A01 file changed, 2 insertions(+), 3 deletions(-)
>=20
> Yes, I checked that. But would be better to change that now?
> Because:
> - could take years to anyone to touch the code, as the code already
> works very well
> - be more standardized could facilitate reading the code
> - It's a good way to encourage new people to contribute to the code

The last one bullet point is what staging is for.

It might be better to do them all at once:

$ git grep --name-only "\bu_int" net/netfilter/ | \
=A0 xargs perl -p -i -e 's/\bu_int(\d+)_t\b/u\1/g'
