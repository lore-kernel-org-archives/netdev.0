From: Valdis.Kletnieks@vt.edu
Subject: Re: Weird modem behaviour in 2.5.73-mm1
Date: Fri, 27 Jun 2003 10:26:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306271426.h5REQvjK006106@turing-police.cc.vt.edu>
References: <200306242102.49356.kde@myrealbox.com> <200306250327.h5P3RwH8001577@turing-police.cc.vt.edu> <200306250418.h5P4IWdA001565@turing-police.cc.vt.edu> <20030625091013.573f2e7b.shemminger@osdl.org> <200306251654.h5PGsUdA022467@turing-police.cc.vt.edu> <20030625102134.2046b04f.shemminger@osdl.org> <200306251804.h5PI4odA023590@turing-police.cc.vt.edu>
            <20030625173549.561cfaec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1444366336P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: Your message of "Wed, 25 Jun 2003 17:35:49 PDT."
             <20030625173549.561cfaec.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-1444366336P
Content-Type: text/plain; charset=us-ascii

On Wed, 25 Jun 2003 17:35:49 PDT, Stephen Hemminger said:
> Try this patch, it is more paranoid in some of the code paths.
> I did get PPP over a null modem cable working between 2.4.18 and 2.5.73 with 
the PPP patches.

I wasn't able to get this patch to apply cleanly to either the replacement .c you sent or
to any of the .c's I already had - which version was this based from?

Also, the entire-replacement .c showed the same symptoms of a quick death as
the problem cset from bitkeeper.  Here's some more info:  In the *working* version,
the first few lines logged by 'pppd -d' are:

Jun 27 10:02:28 turing-police pppd[999]: Using interface ppp0
Jun 27 10:02:28 turing-police pppd[999]: Connect: ppp0 <--> /dev/ttyS14
Jun 27 10:02:28 turing-police /etc/hotplug/net.agent: NET add event not supported
Jun 27 10:02:29 turing-police pppd[999]: sent [LCP ConfReq id=0x1 <asyncmap 0x0> <magic 0x7e941686> <pcomp> <accomp>]
Jun 27 10:02:32 turing-police pppd[999]: sent [LCP ConfReq id=0x1 <asyncmap 0x0> <magic 0x7e941686> <pcomp> <accomp>]
(broken version dies here)
Jun 27 10:02:32 turing-police pppd[999]: rcvd [LCP ConfReq id=0xa3 <asyncmap 0xa0000> <auth pap> <magic 0xa55eea11> <pcomp> <accomp>]
Jun 27 10:02:32 turing-police pppd[999]: sent [LCP ConfAck id=0xa3 <asyncmap 0xa0000> <auth pap> <magic 0xa55eea11> <pcomp> <accomp>]
Jun 27 10:02:32 turing-police pppd[999]: rcvd [LCP ConfAck id=0x1 <asyncmap 0x0> <magic 0x7e941686> <pcomp> <accomp>]

so I'm thinking there's some breakage decoding that next rcvd packet...

My next step is to go through each separate change in the cset that's causing the
problem and apply it, and see which one breaks it.  

--==_Exmh_-1444366336P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE+/FQwcC3lWbTT17ARAgffAJ9hVhsbaNs9Ky6MYf9FjqKZ7oKnlwCfbsw/
A7Xuhcqh5+w8Ag4wU1XvyYc=
=GjNy
-----END PGP SIGNATURE-----

--==_Exmh_-1444366336P--
