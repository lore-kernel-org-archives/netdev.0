From: Paul.Hampson@anu.edu.au (Paul Hampson)
Subject: Kernel Oops (sig11) near vlan_dev_ioctl in 2.6.8.1
Date: Tue, 21 Sep 2004 16:08:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921060824.GA14840@keitarou.bubblesworth.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I recently tried to upgrade my PowerPC machine (NewWorld G4) to
2.6.8.1 from 2.6.5.

I am seeing a Kernel Oops (as detailed below) during the
init.d stage of the boot sequence.

The kernel is 2.6.8.1 + usagi-linux26-s20040816-2.6.8.1.diff.bz2
+ CONNMARK + imq supprt (none of which touch vlan or sungem as I
can see.) w/CONFIG_VLAN support and a sungem e1000 NIC.

My initial thought was the change in buffer size for sungem from
ETH_FRAME_LEN to max(mtu + ETH_HLEN + VLAN_HLEN, VLAN_ETH_FRAME_LEN)
but I've satisfied myself that's not it as my mtu is 1500 so the new
buffer size is _bigger_ than the old one. The VLans have an mtu of
1496 which should the same buffer size as in 2.6.5. (These mtu
settings are from the 2.6.5 kernel, but I expect they came out the
same when I booted 2.6.8.1)

Hence, I expected it's the addition of vlan_dev_ioctl. It's hard
for me to debug as the machine is a production server and I _hate_
taking it down for more than the few minutes a reboot seems to
take. However, upon closer inspection, that seems to be fine too. A
brief glance at snmpd's code appears to be calling either SIOCGMIIPHY
or SIOCGMIIREG.

So I'm left looking at the call to down() at sungem.c:2521... This's
the point where I get left behind, and decided to punt to a mailing
list. I'm not _positive_ it's a netdev bug, but someone else reported
an oops with 2.6.8.1 last week, with the e1000 driver, also upon
recipt of an ioctl that gets to vlan_dev_ioctl, and Ben Greer said
that there were locking changes in the VLAN code which broke and then
someone subsequently fixed, but didn't say if the fix had made it into
any -rc versions or otherwise. I don't see anything immediately useful
in 2.6.9-rc2. >_<

(http://oss.sgi.com/archives/netdev/2004-09/msg00428.html)

Anyway, here's the oops. I'm not subscribed to netdev, so please CC
me on any discussion, and feel free to ask me difficult questions
about my setup or anything else I've not included sufficiently in
this email. I've never reported a kernel oops before, usually someone
else hits it first and fixes it before I get this far. ^_^

Sep 14 02:21:08 obiwan kernel: Oops: kernel access of bad area, sig: 11 [#1]
Sep 14 02:21:08 obiwan kernel: NIP: C0019D3C LR: C01C9A80 SP: D9C47D80 REGS=
: d9c47cd0 TRAP: 0300    Not tainted
Sep 14 02:21:08 obiwan kernel: MSR: 00001032 EE: 0 PR: 0 FP: 0 ME: 1 IR/DR:=
 11
Sep 14 02:21:08 obiwan kernel: DAR: 00000000, DSISR: 42000000
Sep 14 02:21:08 obiwan kernel: TASK =3D dba17320[1860] 'snmpd' THREAD: d9c4=
6000Last syscall: 54
Sep 14 02:21:08 obiwan kernel: GPR00: 00001032 D9C47D80 DBA17320 DB2B3240 D=
9C47D9C 00008947 65B4CB56 00000000
Sep 14 02:21:08 obiwan kernel: GPR08: 00000000 00009032 00000004 00000000 2=
8002482 1001E368 00000000 100C0000
Sep 14 02:21:08 obiwan kernel: GPR16: 00000000 7FFFEA88 100D20A8 0FF1A184 0=
FF1A138 00000000 0FF1A138 00000000
Sep 14 02:21:08 obiwan kernel: GPR24: 00989680 D9C47E20 D9C47D90 D9C47E20 D=
B2B3240 DBA17320 DB2B323C DB2B323C
Sep 14 02:21:08 obiwan kernel: NIP [c0019d3c] add_wait_queue_exclusive+0x28=
/0x38
Sep 14 02:21:08 obiwan kernel: LR [c01c9a80] __down+0x54/0xe8
Sep 14 02:21:08 obiwan kernel: Call trace:
Sep 14 02:21:08 obiwan kernel:  [de1a3610] gem_ioctl+0x144/0x148 [sungem]
Sep 14 02:21:08 obiwan kernel:  [c01c9258] vlan_dev_ioctl+0xb4/0xd4
Sep 14 02:21:08 obiwan kernel:  [c013bfac] dev_ifsioc+0x390/0x400
Sep 14 02:21:08 obiwan kernel:  [c013c1e8] dev_ioctl+0x1cc/0x3ac
Sep 14 02:21:08 obiwan kernel:  [c0180224] inet_ioctl+0xb8/0xcc
Sep 14 02:21:08 obiwan kernel:  [c01304f4] sock_ioctl+0xd8/0x2e0
Sep 14 02:21:08 obiwan kernel:  [c006f730] sys_ioctl+0xdc/0x2f4
Sep 14 02:21:08 obiwan kernel:  [c0007ce0] ret_from_syscall+0x0/0x44

--=20
-----------------------------------------------------------
Paul "TBBle" Hampson, MCSE
7th year CompSci/Asian Studies student, ANU
The Boss, Bubblesworth Pty Ltd (ABN: 51 095 284 361)
Paul.Hampson@Anu.edu.au

"No survivors? Then where do the stories come from I wonder?"
-- Capt. Jack Sparrow, "Pirates of the Caribbean"

This email is licensed to the recipient for non-commercial
use, duplication and distribution.
-----------------------------------------------------------

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBT8VYexDuohKLFuARAii0AKCRBIwhHi/yT2jI5lBETcHxOjdtTgCgniaG
Cbj22KK3AGNDiXDK4akgRpQ=
=85Df
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
