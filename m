From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 21:06:24 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409072106.28334.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409072022.14330.vkondra@mail.ru> <20040907103203.52199758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1554531.97eGOXWn7S";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040907103203.52199758.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1554531.97eGOXWn7S
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

DS> > - there are cases when PHY information needed, to make decisions (like
 select DS> > AP from list), or for information purposes (sniffer). What is
 your vision how DS> > to do this? I.e. provide some standard PHY header
 before MAC header, out of DS> > band (use cb?)
DS>
DS> This should be stored in the 802.11 specific information struct which
DS> I allocate for each generic device which registers with the 802.11
DS> layer.  There should be a standard 802.11 stack interface the driver
DS> can use the pass the information in so that the details of the layout
DS> inside of the 802.11 device information structure need not be exported
DS> publicly.
DS>
DS> > - there is PHY level information that may be needed for Tx:
DS> > modulation;rate;retry policy and rates;Tx power;protection(RTS/CTS, C=
TS
 to DS> > self). Same question as above: how to provide it?
DS>
DS> Same way.

May be I did not stated the question clearly. This information need to be=20
specified per packet. So question ramains: how to specify PHY info per skb.

DS>
DS> > - there is some interesting information that may come from Tx status,
 like DS> > success indication, last rate, retry count, energy in channel
 after packet, DS> > actual backoff time.
DS>
DS> Feed it back into the software stack with some kind of function call.
DS>
I tend to agree, with one note that it should be some mechanism to associat=
e=20
this information with original packet. One implementation example would be =
to=20
keep original skb in some "in process" queue, and actually free it after Tx=
=20
status arrival.

--nextPart1554531.97eGOXWn7S
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBPfikqxdj7mhC6o0RAiijAKCG1fmGpqfZ6gHtKGSB/adxuCe0FgCeMpk+
UwVP3MYd0InzHQF1JWAWCYQ=
=Zv0P
-----END PGP SIGNATURE-----

--nextPart1554531.97eGOXWn7S--
