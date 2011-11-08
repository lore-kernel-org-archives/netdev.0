From: Chris Siebenmann <cks@cs.toronto.edu>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 01:17:37 -0500
Message-ID: <20111108061737.B04D236221@apps0.cs.toronto.edu>
References: <1320684905.2361.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Siebenmann <cks@cs.toronto.edu>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:60537 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab1KHGRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 01:17:38 -0500
In-reply-to: eric.dumazet's message of Mon, 07 Nov 2011 17:55:05 +0100.
             <1320684905.2361.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Le lundi 07 novembre 2011 =C3=A0 11:21 -0500, Chris Siebenmann a =C3=A9=
crit :
| > I have a weird problem where a GRE tunnel periodically won't transm=
it
| > some (TCP) packets, while at the same time it will transmit others =
just
| > fine. This is happening in the current kernel.org git head kernel a=
s
| > well as earlier ones.
[...]
| Do you have any errors on :
|=20
| ip -s -d link show dev greXXXX

 I do indeed. When the problem is happening, I see TX errors counting
up one-for-one with packets that are not transmitted (and no RX
errors). Otherwise I don't see any errors. The other end of the GRE
tunnel shows no errors (TX or RX).

 Further information: when the problem is not happening, SSH doesn't
seem to transmit 500-data-octet packets during startup. Instead I see:

	IP 128.100.3.52.42538 > 128.100.3.51.ssh: Flags [.], seq 22:824, ack 2=
2, win 91, options [nop,nop,TS val 1393299 ecr 29703771], length 802

 I have also once seen an 'ip route show table cache' entry for a route
through the GRE tunnel with 552-byte MTU listed:

	24.173.24.46 from 128.100.3.52 dev extun=20
	    cache  expires 21333540sec ipid 0x9e5c mtu 552

I haven't been able to reproduce this. I have seen listed mtu figures
in 'ip route show table cache' output routinely drop to 774, though.

(I would like to have more data on this but inconveniently the problem
is now not reproducing itself. When it comes back I'll capture more
information about route cache mtu values and error counts and see if
there's anything interesting.)

	- cks
