From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Fireflier-devel] Re: [PATCH][RFC] Security marking
Date: Fri, 28 Apr 2006 09:19:04 +0200
Message-ID: <4451C1E8.9040104@trash.net>
References: <20060417184053.6D618378FD@localhost.localdomain> <Pine.LNX.4.64.0604172051510.20174@d.namei> <200604232157.59758.edwin@gurde.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	fireflier-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6053 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S1030287AbWD1HTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 03:19:06 -0400
To: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwin@gurde.com>
In-Reply-To: <200604232157.59758.edwin@gurde.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T=F6r=F6k Edwin wrote:
> Patrick what is the status of solving the skfilter issues? Can I help=
 with=20
> testing patches,  etc.?

Not yet. If nothing gets in between I plan to get the patches ready
next week.

> On Monday 20 February 2006 18:42, Patrick McHardy wrote:
>=20
>>Confirmation of conntrack entries. They shouldn't be confirmed before
>>packets have passed the socket hooks. This is the tricky part because
>>we don't know if packets will be delivered to a raw socket or not
>>when calling the regular LOCAL_IN hook.
>>The only way to solve this=20
>>seems to be to use the socket hooks for all incoming packets, that
>>way we can defer confirmation unconditionally.
>=20
> Are there any problems with using socket hooks for all packets?

Not really, just that some protocols don't use sockets, so its a bit
pointless for them. OTOH it should make rule management easier if
everything can be done in the same table.

>>The nicest way would=20
>>be to just move the regular LOCAL_IN hook to the socket hooks, but
>>this doesn't work with SNAT in LOCAL_IN because the socket lookup
>>needs the already NATed address.
>=20
> Move just the non SNAT part of LOCAL_IN to socket hooks?(does this ma=
ke=20
> sense?)

That would be my prefered way, but it changes user-visible behaviour.
Currently filtering is done before SNAT, this change would reverse
that.
