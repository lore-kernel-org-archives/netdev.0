From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 04 Nov 2009 06:03:25 +0100
Message-ID: <4AF10B1D.4050604@gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam> <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44437 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbZKDFDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 00:03:30 -0500
In-Reply-To: <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano a =E9crit :
> Hi Patrick and Stephen,
>=20
> Thanks for your comments.
>=20
> I retried on the newer kernel and iproute2, and added the experimenta=
l result
> on my page.  Please see 'Experimental result 2':
>     http://code.google.com/p/pspacer/wiki/HTBon10GbE
>=20
> The accuracy improves compared with the previous experiment.
> The difference reduces from +810 Mbps to +430 Mbps.
> It is because the timer resolution improves from 1 usec to 1/64 usec.
> But it is not perfect.
>=20

Hmm, do you know part of the error comes from the user tool itself ?

If you check iperf results at sender and receiver you'll see different
values, sender lies a bit.

Tried here on a Gbit link (I dont have 10Gbe yet)

$ ./iperf.bench.sh
=2E100 104
=2E200 206
=2E300 307
=2E400 413
=2E500 515
=2E600 610
=2E700 715
=2E800 822
=2E900 913
1.000 945

while on receiver :
[  4]  0.0- 5.3 sec  62.8 MBytes    100 Mbits/sec
[  5]  0.0- 5.1 sec    123 MBytes    202 Mbits/sec
[  4]  0.0- 5.1 sec    183 MBytes    303 Mbits/sec
[  5]  0.0- 5.1 sec    246 MBytes    409 Mbits/sec
[  4]  0.0- 5.0 sec    307 MBytes    511 Mbits/sec
[  5]  0.0- 5.0 sec    364 MBytes    607 Mbits/sec
[  4]  0.0- 5.0 sec    427 MBytes    711 Mbits/sec
[  5]  0.0- 5.0 sec    490 MBytes    818 Mbits/sec
[  4]  0.0- 5.0 sec    545 MBytes    909 Mbits/sec
[  5]  0.0- 5.0 sec    565 MBytes    941 Mbits/sec


You might use longer intervals to reduce this error (10 secs instead of=
 5 secs)

$./iperf.bench.sh
=2E100 102
=2E200 204
=2E300 305
=2E400 410
=2E500 513
=2E600 608
=2E700 713
=2E800 820
=2E900 911
1.000 943
