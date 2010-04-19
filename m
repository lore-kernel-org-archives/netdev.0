From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Mon, 19 Apr 2010 13:09:05 -0700 (PDT)
Message-ID: <20100419.130905.210660275.davem@davemloft.net>
References: <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
	<1271452358.16881.4486.camel@edumazet-laptop>
	<1271520633.16881.4754.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923Ab0DSUJB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 16:09:01 -0400
In-Reply-To: <1271520633.16881.4754.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Apr 2010 18:10:33 +0200

> Le vendredi 16 avril 2010 =E0 23:12 +0200, Eric Dumazet a =E9crit :
>> My results are on a "tbench 16" on an dual X5570  @ 2.93GHz.
>> (16 logical cpus)
>>=20
>> No RPS , no RFS : 4448.14 MB/sec=20
>> RPS : 2298.00 MB/sec (but lot of variation)
>> RFS : 2600 MB/sec
>>=20
>> Maybe my RFS setup is bad ?
>> (8192 flows)
>>=20
>=20
> With attached patch, I reached=20
>=20
> Throughput 4465.13 MB/sec 16 procs
>=20
> RFS better than no RPS/RFS :)
>=20
> So, the old idea to make rxhash consistent (same value in both
> directions) is a win for some workloads (Consider connection tracking=
 /
> firewalling)=20

=46un :-)  I toyed around with this on my 128 cpu machine (2 NUMA
nodes, 64 cpus each NUMA node).

Vanilla net-next-2.6, no configuration changes:

tbench 64: Throughput 1843.43 MB/sec 64 procs
tbench 128: Throughput 1889.67 MB/sec 128 procs

Vanilla net-next-2.6, rps_cpus=3D"ffffffff,ffffffff,ffffffff,ffffffff"

tbench 64: Throughput 1455.89 MB/sec 64 procs
tbench 128: Throughput 2009.91 MB/sec 128 procs

net-next-2.6 + Eric's port hashing patch, rps_cpus=3D"ffffffff,ffffffff=
,ffffffff,ffffffff"

tbench 64: Throughput 1593.13 MB/sec 64 procs
tbench 128: Throughput 2367.27 MB/sec 128 procs

