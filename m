From: jamal <hadi@cyberus.ca>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Wed, 31 Jul 2002 07:46:28 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207310741410.21096-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0207300947190.1266-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <kuznet@ms2.inr.ac.ru>, bert hubert <ahu@ds9a.nl>, <netdev@oss.sgi.com>,
   <akpm@zip.com.au>, <jgarzik@mandrakesoft.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0207300947190.1266-100000@beohost.scyld.com>
List-Id: netdev.vger.kernel.org



On Tue, 30 Jul 2002, Donald Becker wrote:

> 	int csum_bits = rx_status & 0xee000000;
> 	if (csum_bits &&
> 		(csum_bits == (IPChksumValid | TCPChksumValid) ||
> 		 csum_bits == (IPChksumValid | UDPChksumValid))) {
> 		skb->ip_summed = CHECKSUM_UNNECESSARY;
>
> Note that this relies on the kernel to make the final decision that the
> checksum is invalid.
>
> [[ This is the correct semantics: the driver might indicate that a protocol
>    level checksum is correct, but it should not discard packets based
>    on its (necessarily limited) understanding of higher level protocols.
> ]]
>

Nod.
So is CHECKSUM_WRONG needed to give a hint to the stack? It is possible
IPcsum is right but not the transport; Maybe ip_summed needs to be a
bitmap then?
You could use the information to move packets out of the stack fastpath
for example.

cheers,
jamal
