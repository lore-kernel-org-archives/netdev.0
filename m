From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [0/2] netxen: bug fix and diagnostics for possible (hardware?)
 bug
Date: Fri, 24 Jan 2014 17:44:11 +1100
Message-ID: <20140124064411.GC4361@voom.redhat.com>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <31AFFC7280259C4184970ABA9AFE8B938CF85726@avmb3.qlogic.org>
 <20131218062231.GB32453@voom.fritz.box>
 <31AFFC7280259C4184970ABA9AFE8B938CF868E9@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bajzpZikUji1w+G9"
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44400 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbaAXGoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 01:44:17 -0500
Content-Disposition: inline
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B938CF868E9@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bajzpZikUji1w+G9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 19, 2013 at 09:11:33AM +0000, Manish Chopra wrote:
> >> >From: David Gibson [mailto:david@gibson.dropbear.id.au]
> >> >Sent: Tuesday, December 17, 2013 10:53 AM
> >> >To: Manish Chopra; Sony Chacko; Rajesh Borundia
> >> >Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
> >> >vdasgupt@redhat.com
> >> >Subject: [0/2] netxen: bug fix and diagnostics for possible
> >> >(hardware?) bug
> >> >
> >> >At Red Hat, we've hit a couple of customer cases with crashes in the
> >> >netxen driver due to list corruption.  This seems to be very rarely
> >> >triggered, and unfortunately the dumps we have don't have enough
> >> >information to be certain of the cause, although we have a possible t=
heory.
> >> >
> >> >I'm suggesting, therefore a patch to add some sanity checking which
> >> >should help to at least localize and mitigate the problem when someon=
e hits it
> >in future.
> >> >Please let me know if there's a better approach to doing this.
> >> >
> >> >That's 2/2.  1/2 is a fix for a clear bug I spotted along the way,
> >> >but not one that could cause the symptoms we've seen.
> >>
> >> David,
> >>
> >> Having these checks in data path(Rx path) may have some performance
> >> impact. It's better to root cause it instead of putting some sanity
> >> checks.
> >
> >Obviously, but this was the best way I could think of to try narrowing d=
own the
> >root cause (at least trying to eliminate driver vs. firmware bug).
>=20
> David, Instead of making permanent changes in driver, can you please
> run your modified driver in selective customer environment where
> this issues is seen?

Yeah, the problem with that is that the problem has never triggered
twice for a single customer.  Well, technically there is one customer
that's hit it twice, but I'm pretty sure it's on entirely unrelated
systems in different sections of a large customer.  The only reason I
can see enough cases to suspect a pattern to these problems is from
looking across Red Hat's whole case history.

> Which may give some data point that what's the issue exactly and then we =
go by that.
>=20
> >
> >> We will get back to you on this.
> >
> >If you have a better idea for locating the root cause, please let me kno=
w.  I have
> >access to a vmcore which I can poke around in.
>=20
> We will also try to reproduce the problem in our environment and debug th=
is.
> Can you please give some details?

Apologies for the long delay, I'd been hoping for some more
confirmation of things, but it hasn't happened.  I'll give you what I
can.

> 1) what's the driver and firmware version used?

I'm not sure what the most useful way ot giving a driver version.
I've given kernel version below, but it's an RH kernel, so I'm not
sure how much has been backported.

As to firmware, the driver reports:

netxen_nic 0000:04:00.0: Gen2 strapping detected
netxen_nic 0000:04:00.0: using 64-bit dma mask
netxen_nic: NX3031 Gigabit Ethernet Board S/N
<FF><FF><FF><FF><FF><FF><FF><FF><FF>
<FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF><FF=
><FF>
<FF><FF><FF>NX3031 Gigabit Ethernet  Chip rev 0x42
netxen_nic 0000:04:00.0: firmware v4.0.585 [legacy]

> 2) which operating system and kernel version?

RHEL5,=20

Linux hostname 2.6.18-308.el5 #1 SMP Fri Jan 27 17:17:51 EST 2012 x86_64 x8=
6_64 x86_64 GNU/Linux

> 3) please send the vmcore also with backtrace if available which can
> give some idea what can trigger this issue.

I can't send the vmcore itself, since it will include customer data.
I can give you the backtrace below, and look up specific things if you
can give me an idea of what you need:

crash> bt
PID: 0      TASK: ffff81207f8bd7e0  CPU: 44  COMMAND: "swapper"
 #0 [ffff81107fd33b40] crash_kexec at ffffffff800b0938
 #1 [ffff81107fd33c00] __die at ffffffff80065137
 #2 [ffff81107fd33c40] die at ffffffff8006c789
 #3 [ffff81107fd33c70] do_invalid_op at ffffffff8006cd49
 #4 [ffff81107fd33d30] error_exit at ffffffff8005dde9
    [exception RIP: list_del+71]
    RIP: ffffffff8015a793  RSP: ffff81107fd33de0  RFLAGS: 00010286
    RAX: 0000000000000058  RBX: 0000000000000427  RCX: ffffffff80323028
    RDX: ffffffff80323028  RSI: 0000000000000000  RDI: ffffffff80323020
    RBP: ffff81407f4e8680   R8: ffffffff80323028   R9: 0000000000000001
    R10: 0000000000000000  R11: 0000000000000000  R12: ffffc200104494a0
    R13: 0000000000000002  R14: ffff81107a2cf500  R15: ffff81407e1bf400
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #5 [ffff81107fd33de8] netxen_process_rcv_ring at ffffffff8830b050 [netxen_=
nic]
 #6 [ffff81107fd33eb8] netxen_nic_poll at ffffffff88306e71 [netxen_nic]
 #7 [ffff81107fd33ef8] net_rx_action at ffffffff8000c9b9
 #8 [ffff81107fd33f38] __do_softirq at ffffffff80012551
 #9 [ffff81107fd33f68] call_softirq at ffffffff8005e2fc
#10 [ffff81107fd33f80] do_softirq at ffffffff8006d646
#11 [ffff81107fd33f90] do_IRQ at ffffffff8006d4d6
--- <IRQ stack> ---
#12 [ffff81307fe2fe38] ret_from_intr at ffffffff8005d615
    [exception RIP: mwait_idle_with_hints+102]
    RIP: ffffffff8006b9cf  RSP: ffff81307fe2fee8  RFLAGS: 00000246
    RAX: 0000000000000000  RBX: 00000000000000ff  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000000
    RBP: 00007f319bfb6f27   R8: ffff81307fe2e000   R9: 0000000000000013
    R10: ffff8110b8288510  R11: 00000000ffffffff  R12: ffff81306273d040
    R13: ffff81207f8bd7e0  R14: 0000000000000001  R15: 0000000000000000
    ORIG_RAX: ffffffffffffff64  CS: 0010  SS: 0018
#13 [ffff81307fe2fee8] mwait_idle at ffffffff80056c65
#14 [ffff81307fe2fef0] cpu_idle at ffffffff80048f92

> 4) Test case details:- what type of test is running on the system?
> Just to make sure we also try the same test cases in our
> environment.

No particular type of test, it's an Oracle server in production.

> 5) Server details (Number of CPus, memory etc.) if available.

64 x Xeon X7550 CPUs, 256G RAM

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--bajzpZikUji1w+G9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJS4gu7AAoJEGw4ysog2bOSUZMP/0+/P6CIKBgdMnUdjLNrjJNr
6xLlK9g18/5A13fJJgOGkO4F+jhtvc/6TWJAravVU6yQ0hiRnPYvGRotgY9ZQwgU
4iAIZ7nUUI4YI5c5Uiac+bhGF89KAuZwZvlW1hK4N0X9yAYF1neKjYuOqXUZAH1d
LuHP4vYAdhogPReQKiKI0HN/pl1O6smpxQxG2+2ZxKpizKuYgIvxGu0iW1MFTki9
vaQYhdK1K/X/ySaEAD3RRucZdWZFZKxlN6iZdUtTaEyG45TsqtiyCIJSX/0CtB1Q
JTm5roU4py9M/lY9TyNYcnropCrtoVzCWcFdZkZigr2MEYWJlfPc5G8J6ZI/saCD
KKwrSVM1zrWaFYJqMTcp6j0k/0dUFYotS7gwwL2SmT/U5UDVvEOvskxIBlOri6/N
cfEPC3fmFFYok10dldK40mOkKizyiLcQtoO7omkbQlpPN60QS/CA8nIO1CKgUIjJ
+aZpWS1qyq7p0/5lWiy88nnhK6GBB7+AJ8n0iRNOZzq3cmkpUhvW6LELWLdPbLbI
sQSC7aCP0N/WnInfi9LwEKwC1eooFAFrFiYppHHqqH5RZNMQ2P7eMMcxNgOKUSCO
s/QSO0cTzdWOnPNUyAYp7Il8Rf6cOvU8ERiV0Va1Ep6ev1c6l3oIAsDaXNenLVRz
xeI9lk1S7xsYDjML312v
=bzvT
-----END PGP SIGNATURE-----

--bajzpZikUji1w+G9--
