From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Wed, 20 Apr 2016 09:32:20 +0200
Message-ID: <1461137540.2176.5.camel@sipsolutions.net>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	 <20160418.235207.395468709808133833.davem@davemloft.net>
	 <1461060543.2766.20.camel@sipsolutions.net>
	 <20160419.142324.1774057494079734967.davem@davemloft.net>
	 <1461094901.2766.26.camel@sipsolutions.net>
	 <5716E123.8040002@cumulusnetworks.com>
	 (sfid-20160420_035344_487995_3E03AD21)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, egrumbach@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55241 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbcDTHc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 03:32:27 -0400
In-Reply-To: <5716E123.8040002@cumulusnetworks.com> (sfid-20160420_035344_487995_3E03AD21)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 19:53 -0600, David Ahern wrote:
>=C2=A0
> The kernel can set a flag in the response that it acknowledges the
> new =C2=A0attribute/flag. I did that for filtering neigh dumps --
> 21fdd092acc7.
>=20

Hm, that works, but I think it requires writing extra code, which I was
kinda trying to avoid. With the patch that Emmanuel wrote, we can
restrict the changes to just nla_parse().

Anyway, I think we just have to document the behaviour very precisely,
and userspace can make its own decisions.

Essentially, apps will have a number of choices:

1) Use the new attribute flag only with commands known to have been
=C2=A0 =C2=A0added after the kernel support was added.

2) Use the new attribute flag with some required attribute for
=C2=A0 =C2=A0existing commands, so that older kernel will not find the =
required
=C2=A0 =C2=A0attribute and will reject the operation entirely.
=C2=A0 =C2=A0May or may not fall back to trying the operation again wit=
hout the
=C2=A0 =C2=A0flag.

3) Simply use the new flag and do unexpected things on kernels not
=C2=A0 =C2=A0supporting the rejection mechanism - not much worse than t=
oday in
=C2=A0 =C2=A0many cases.

I guess we'll write a proper commit message and send the patch.

johannes
