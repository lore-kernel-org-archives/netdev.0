From: pollockd@magma.ca
Subject: Re: Realtek 8169 Lock-ups
Date: Tue, 13 Jan 2004 11:55:41 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1074012941.5886.12.camel@localhost>
References: <200401111623.i0BGNg3O028990@webmail1.magma.ca>
	 <4001A41C.3070205@pobox.com>
Reply-To: dpollock@acm.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AiLDoAMaC7ybRbg9RUED"
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        damouse@ntlworld.com, brad@mainstreetsoftworks.com,
        kinetik@orcon.net.nz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4001A41C.3070205@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-AiLDoAMaC7ybRbg9RUED
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2004-01-11 at 14:29, Jeff Garzik wrote:
> Douglas Pollock wrote:
> The kernel comes with "pktgen" which is a free packet generator you can=20
> use for stressing kernels and LANs.  There is also ttcp, nttcp, various=20
> filesystems tests over NFS (such as bonnie++), various block device=20
> tests over nbd (network block device), ...

Thanks for that.  I should have remembered the packet generator.  Using
pktgen, I am able to reproduce the problem.


HARDWARE:
Intel P4 with hyper-threading enabled
Realtek 8169 (rev. 10)
Switched 100Mbps network
A second machine on the same network (to receive test packets)

SOFTWARE:
Kernel 2.6.0 or 2.6.1-rc1 (possibly others), with SMP for 2 processors,
Realtek 8169 driver, and packet generator


STEPS TO REPRODUCE:
1.) Set up the ipg script to send to the second machine on the 8169 NIC.
2.) pgset pkt_size 9014
3.) pg


OBSERVATIONS:
Soon after step #3, the 8169 NIC will stop responding (note: the netdev
watchdog reports a timeout in dmesg).  No packets get through.  However,
everything else still works.  Disabling SMP in the kernel fixes this
problem.



Doug.

--=-AiLDoAMaC7ybRbg9RUED
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBABCMLLhh1LVU8SusRAtTXAJoCQdN5E8uvmbm6LeDVBfZD6DJ/DwCgrIsb
wWWlcJD8EzfThXM3bVUX3Kk=
=fKX6
-----END PGP SIGNATURE-----

--=-AiLDoAMaC7ybRbg9RUED--
