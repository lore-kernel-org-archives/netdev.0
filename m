From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 07:42:17 +0200
Message-ID: <4535BEB9.3010400@cosmosbay.com>
References: <4415A4C1.1030906@cosmosbay.com> <452EA214.7080905@cosmosbay.com>
 <4535B6B7.4070107@cosmosbay.com>
 <20061017.222709.130237201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604002mt.neufgp.fr ([84.96.92.61]:36278 "EHLO sMtp.neuf.fr")
	by vger.kernel.org with ESMTP id S1751376AbWJRFmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 01:42:18 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604002mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7B009JMH6HJU63@sp604002mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Wed, 18 Oct 2006 07:42:17 +0200 (CEST)
In-reply-to: <20061017.222709.130237201.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 18 Oct 2006 07:08:07 +0200
>=20
>> Each route entry includes a 'struct flow'. This structure has a
>> current size of 80 bytes. This patch makes a size reduction
>> depending on
>> CONFIG_IPV6/CONFIG_IPV6_MODULE/CONFIG_DECNET/CONFIG_IP_ROUTE_FWMARK
>> For a platform doing IPV4 only, the new size is 36 bytes (instead of
>> 80) As many routers are base on PIII (L1_CACHE_SIZE=3D32), this save=
s
>> one cache line per rtable entry.
>=20
> I don't like these kinds of patches because %99 of people will never
> ever realize the "savings" because distribution vendors will always,
> unlaterally, enable everything.
>=20
> For example, I'm still pending to cut the patch that kills the "struc=
t
> flow" from inet_sock's cork area since it really isn't needed.
>=20
> I'd rather do things that get rid of the size in a way that benefits
> everyone, regardless of kernel config.  I also would totally support
> a patch that got rid of all the config ifdefs used in struct sk_buff.

I agree with you David (I dont like these patches as well), but I know =
a lot=20
of sysadmins who recompile themselves their kernels because they have o=
ld=20
machines and/or want optimized kernels, not 'big bloated kernels' from =
distro=20
guys running the very latest intel/amd bomb.

As long the #ifdefs are in .h files, I do think the pain is small.

=46act is linux has many CONFIG_XXXX things, and as many possible binar=
y=20
versions for a single linux-2.6.XX version as atoms in the universe... =
A=20
distro cannot provides all version and just provide the largest possibl=
e one,=20
containing many obsolete/funny features.

How many people are using DECNET and want to pay the price of this 20 b=
ytes=20
dnports structure ?

Eric
