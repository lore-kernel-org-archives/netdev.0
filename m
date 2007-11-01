From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Thu, 01 Nov 2007 14:46:39 -0700 (PDT)
Message-ID: <20071101.144639.178775530.davem@davemloft.net>
References: <4729A774.9030409@cosmosbay.com>
	<20071101091456.26248ce0@freepuppy.rosehill>
	<472A12D0.4070401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	ak@suse.de, acme@redhat.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752860AbXKAVqk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 17:46:40 -0400
In-Reply-To: <472A12D0.4070401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 01 Nov 2007 18:54:24 +0100

> Stephen Hemminger a =E9crit :
> > Longterm is there any chance of using rcu for this? Seems like
> > it could be a big win.
>=20
> This was discussed in the past, and I even believe some patch was pro=
posed,=20
> but some guys (including David) complained that RCU is well suited fo=
r 'mostly=20
>   read' structures.
>=20
> On some web server workloads, TCP hash table is constantly accessed i=
n write=20
> mode (socket creation, socket move to timewait state, socket  deleted=
=2E..), and=20
> RCU added overhead and poor cache re-use (because sockets must be pla=
ced on=20
> RCU queue before reuse)
>=20
> On these typical workload, hash table without RCU is still the best.

Right, and none of the submitted RCU attempts were correct, it's very
hard to get the synchronization right.

> Longterm changes would rather be based on Robert Olsson suggestion
> last year (trie based lookups and unified IP/TCP cache)
>
> Short term changes would be to be able to resize the TCP hash table (=
being=20
> small at boot, and be able to grow it if necessary). Its current size=
 on=20
> modern machines is just insane.

Resizing the hash is also, unfortunately, very hard to implement
as well.

