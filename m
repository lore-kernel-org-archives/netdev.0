From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 08:12:21 +0200
Message-ID: <49F54CC5.7020600@cosmosbay.com>
References: <20090427030433.GA17454@kryten> <49F53FF6.2040603@cosmosbay.com> <20090427054702.GA15891@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36523 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbZD0GM2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:12:28 -0400
In-Reply-To: <20090427054702.GA15891@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Blanchard a =E9crit :
> =20
> Hi,
>=20
>> Then boot with rhash_entries =3D 8000 ?
>> or=20
>> echo 1 >/proc/sys/net/ipv4/route/gc_interval
>=20
> Yes we are hardwiring it for now.
>=20
>> Sorry this limit is too small. Many of my customer machines would co=
llapse.
>=20
> So what would a reasonable upper limit be? Surely we should cap it at=
 some
> point?
>=20

A similar patch was done for the size of TCP hash table. It was somethi=
ng
like 512 * 1024 if I remember well. IMHO this same value would be fine =
for
IP route cache.

Yes, this was commit :

commit 0ccfe61803ad24f1c0fe5e1f5ce840ff0f3d9660
Author: Jean Delvare <jdelvare@suse.de>
Date:   Tue Oct 30 00:59:25 2007 -0700

    [TCP]: Saner thash_entries default with much memory.

    On systems with a very large amount of memory, the heuristics in
    alloc_large_system_hash() result in a very large TCP established ha=
sh
    table: 16 millions of entries for a 128 GB ia64 system. This makes
    reading from /proc/net/tcp pretty slow (well over a second) and as =
a
    result netstat is slow on these machines. I know that /proc/net/tcp=
 is
    deprecated in favor of tcp_diag, however at the moment netstat only
    knows of the former.

    I am skeptical that such a large TCP established hash is often need=
ed.
    Just because a system has a lot of memory doesn't imply that it wil=
l
    have several millions of concurrent TCP connections. Thus I believe
    that we should put an arbitrary high limit to the size of the TCP
    established hash by default. Users who really need a bigger hash ca=
n
    always use the thash_entries boot parameter to get more.

    I propose 2 millions of entries as the arbitrary high limit. This
    makes /proc/net/tcp reasonably fast on the system in question (0.2 =
s)
    while being still large enough for me to be confident that network
    performance won't suffer.

    This is just one way to limit the hash size, there are others; I am=
 not
    familiar enough with the TCP code to decide which is best. Thus, I
    would welcome the proposals of alternatives.

    [ 2 million is still too large, thus I've modified the limit in the
      change to be '512 * 1024'. -DaveM ]

    Signed-off-by: Jean Delvare <jdelvare@suse.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>



Thanks

