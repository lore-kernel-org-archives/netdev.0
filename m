From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: 4.4.0 - e1000e - possible power management issue
Date: Tue, 19 Apr 2016 21:53:44 +0200
Message-ID: <20160419195344.GA8663@nik-comp.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: nikola.ciprich@linuxbox.cz
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:45222 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753839AbcDSUUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 16:20:01 -0400
Received: from linuxbox.linuxbox.cz (linuxbox.linuxbox.cz [10.76.66.10])
	by gwu.lbox.cz (Sendmail) with ESMTPS id u3JJri4t018806
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 21:53:44 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

after upgrading our firewall from 4.1.17 to 4.4.0, we've noticed quite a pe=
rformance
drop.. Slight network load seems to cause high CPU load..

running perf of almost idle system shows:

             samples  pcnt function                                DSO
             _______ _____ _______________________________________ ________=
___________________________________________________________________

              631.00 20.7% e1000_power_down_phy_copper_80003es2lan /lib/mod=
ules/4.4.0lb6.01/kernel/drivers/net/ethernet/intel/e1000e/e1000e.ko
              191.00  6.3% do_raw_spin_lock                        [kernel.=
kallsyms]                                                         =20
              165.00  5.4% ipt_register_table                      /lib/mod=
ules/4.4.0lb6.01/kernel/net/ipv4/netfilter/ip_tables.ko           =20
              119.00  3.9% cache_init                              /usr/sbi=
n/netstat-probe                                                   =20
              118.00  3.9% __memset_sse2                           /lib64/l=
ibc-2.12.so                                                       =20
               88.00  2.9% cache_write_packet                      /usr/sbi=
n/netstat-probe                                                   =20
               41.00  1.3% __fget                                  [kernel.=
kallsyms]                                                         =20
               40.00  1.3% memcpy                                  [kernel.=
kallsyms]                                                         =20


when there is some network traffic, e1000_power_down_phy_copper_80003es2lan=
 jumps to much higher
numbers.. as far as I understand the code, this seems suspicious to me..

Anyone hit the same problem?

I can try upgrading to 4.4.8-rc1 tomorrow or reverting to 4.1.17

lspci of the box adapters:

05:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Cont=
roller (Copper) (rev 03)
07:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Cont=
roller
09:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Cont=
roller
0b:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Cont=
roller

BR

nik

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799

www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlcWjMgACgkQ3xdJJrLygV7j9QCfQRuXCmTZfcdcGMR22OlRvxyW
TUEAoMZ7lh/plmA97BafsGTHxT8kv0dn
=Y9PN
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
