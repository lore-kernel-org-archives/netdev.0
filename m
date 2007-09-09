From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Sun, 09 Sep 2007 10:44:49 +0200
Message-ID: <46E3B281.4030105@cosmosbay.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com> <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36797 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbXIIIpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 04:45:07 -0400
In-Reply-To: <m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman a =E9crit :
> This is the basic infrastructure needed to support network
> namespaces.  This infrastructure is:
> - Registration functions to support initializing per network
>   namespace data when a network namespaces is created or destroyed.
>=20
> - struct net.  The network namespace data structure.
>   This structure will grow as variables are made per network
>   namespace but this is the minimal starting point.
>=20
> - Functions to grab a reference to the network namespace.
>   I provide both get/put functions that keep a network namespace
>   from being freed.  And hold/release functions serve as weak referen=
ces
>   and will warn if their count is not zero when the data structure
>   is freed.  Useful for dealing with more complicated data structures
>   like the ipv4 route cache.
>=20
> - A list of all of the network namespaces so we can iterate over them=
=2E
>=20
> - A slab for the network namespace data structure allowing leaks
>   to be spotted.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>


Nice work Eric !

"struct net" is not a very descriptive name imho, why dont stick "ns" o=
r=20
"namespace" somewhere ?

Do we really need yet another "struct kmem_cache *net_cachep;" ?
The object is so small that the standard caches should be OK (kzalloc()=
)


