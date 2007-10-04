From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Thu, 04 Oct 2007 16:53:41 +0200
Message-ID: <4704FE75.2030104@fr.ibm.com>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi> <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi> <4703A1BB.1040006@free.fr> <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi> <4703AE04.5090009@free.fr> <4703B16C.2000106@fr.ibm.com> <Pine.LNX.4.64.0710031817540.27745@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:9542 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbXJDOyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 10:54:13 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l94EsB7k428602
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 14:54:11 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l94EsB0k3043338
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 15:54:11 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l94ErsRh012208
	for <netdev@vger.kernel.org>; Thu, 4 Oct 2007 15:53:54 +0100
In-Reply-To: <Pine.LNX.4.64.0710031817540.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>=20
>> Cedric Le Goater wrote:
>>> Below are the messages I got on 2) right after running ketchup (whi=
ch does=20
>>> a wget www.kernel.org)=20
>=20
> Oops, those tcp_fragment WARNINGs in the other mail were due to bug i=
n=20
> the debug patch as it called verify too early in there (before queue =
was=20
> adjusted, no wonder it finds state inconsistent at that point, fixed =
that)...
>=20
> ...So please discard all old debug patches, they're all broken in thi=
s=20
> respect... :-(
>=20
>>> not a warning on 1) with your extra verbose patch.
>> bummer, I got this one on 1) :(
>>
>> WARNING: at /home/legoater/linux/net-2.6.24.git/net/ipv4/tcp_input.c=
:2325 tcp_fastretrans_alert()
>> Call Trace:
>>  <IRQ>  [<ffffffff8022ddb6>] __wake_up+0x1f/0x4c
>>  [<ffffffff803fd9d3>] tcp_ack+0xcee/0x18ac
>>  [<ffffffff80400764>] tcp_rcv_established+0x61f/0x6df
>=20
> ...I just wonder why that's the first place where it occurs... Can yo=
u try=20
> the debug patch below (fixed verify place in tcp_fragment/collapse, a=
dded=20
> some of them to narrow it down, and handled GSO more user friendly wa=
y in=20
> the printout). Put it on top of those three patches (mm should be fin=
e :-)).
> ...I wish the verify triggers way before the fastretrans trap (for so=
me=20
> reason it didn't do that in the quoted trace, maybe I had some verify=
s=20
> missing in that old patch or something)...

so here are the results on a net-2.6.24 kernel.=20

I've put the patchset here to make sure it's correct:=20

	http://legoater.free.fr/patches/2.6.23/net-2.6.24.git-tcp_fastretrans/

and plenty of logs :

	http://legoater.free.fr/patches/2.6.23/net-2.6.24.git-tcp_fastretrans.=
messages

=46YI, config is here :

	http://legoater.free.fr/patches/2.6.23/net-2.6.24.git-tcp_fastretrans.=
config

C.
