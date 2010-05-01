From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Sat, 1 May 2010 13:06:41 +0100
Message-ID: <20100501120641.GA18613@cel.leo>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
 <20100429.233958.212393607.davem@davemloft.net>
 <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
 <20100430.164115.257514715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YZ5djTAD1cGYuMQK"
Cc: therbert@google.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:48867 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752147Ab0EAMGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 May 2010 08:06:43 -0400
Content-Disposition: inline
In-Reply-To: <20100430.164115.257514715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2010 at 04:41:15PM -0700, David Miller wrote:
> If other people have an opinion about this, now would be the time
> to speak up. :-)

I have to say I agree with David.

The "receive timestamp" for a TCP recv() call is completely meaningless.
Each byte in the stream arguably could have a set of receive timestamps,
being the timestamp of the underlying IPv4 packet containing a fragment
of a TCP segment that covered that byte. One recv() call could cover
many packets, many recv() calls could be required to consume one packet.
We just don't know from userland.

The point about IPv4 fragments in UDP is a reasonable one; that because
of IPv4 fragmentation there are still potentially multiple timestamps
that could be relevant to a single UDP recv() call. But no two recv()
calls can possibly relate to the same IPv4 fragments, so I feel this is
more defined. Plus, of all the IPv4 fragments that go into a single UDP
packet, one of them is special - the first one, the one containing the
UDP header. We could easily say "the timestamp of a UDP recv() call
shall be the time at which its header was received, even if other
fragments arrived before or after it".=20

We cannot make any such distinction for some window in a TCP stream. All
TCP segments are indistinct in this manner.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--YZ5djTAD1cGYuMQK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL3BlRvLS2TC8cBo0RAmNTAJ92sBy+gYvmy5bv2sRnVdilV3bXmwCfdqDP
jRmwudl3HEBbrvpygsDg8gQ=
=0yqZ
-----END PGP SIGNATURE-----

--YZ5djTAD1cGYuMQK--
