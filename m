From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Mon, 19 Sep 2011 22:10:37 -0400
Message-ID: <6030.1316484637@turing-police.cc.vt.edu>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1315473888.2301.21.camel@schen9-mobl> <1315544777.5410.19.camel@edumazet-laptop> <20110918.210758.2207266633127640132.davem@davemloft.net> <1316406528.2521.15.camel@edumazet-laptop> <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
            <1316468398.4680.6.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1316484636_2734P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:50183 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab1ITCMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 22:12:40 -0400
In-Reply-To: Your message of "Mon, 19 Sep 2011 14:39:58 PDT."
             <1316468398.4680.6.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1316484636_2734P
Content-Type: text/plain; charset=us-ascii

On Mon, 19 Sep 2011 14:39:58 PDT, Tim Chen said:
> Do we have to worry about the case where peer socket changes its flag
> to SOCK_PASSCRED while packets are in flight?  If there isn't such
> pathological use case, the patch looks fine to me.

I wouldn't think so - if you're sending a packet, and retroactively trying to
change the flag and expect it to work, your program is too ugly to live.  After
all, if the scheduler had cut off your timeslice and scheduledthe receiving
process before you set the flag, that packet would be delivered and done with
anyhow, and no amount of wishing will set that flag on an already-delivered
packet.

What *is* worth checking is that we DTRT if a process/thread is doing a send on
one CPU, and another process/thread with a shared file descriptor for that
socket is diddling the flag.  But if we just define it as "atomic op to change
the flag and other observers get whatever value their CPU sees at that
instant", I'm OK with that too.. ;)


--==_Exmh_1316484636_2734P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOd/YccC3lWbTT17ARAvhqAKC6mVSnoS5KIhwkG0nHbxt6F+quygCdHgUh
OZd+0BADbLk+YucVnICXvlA=
=zD4F
-----END PGP SIGNATURE-----

--==_Exmh_1316484636_2734P--
