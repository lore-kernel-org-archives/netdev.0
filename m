From: Gertjan Hofman <gertjan_hofman@yahoo.com>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Sun, 25 Oct 2009 21:30:09 -0700 (PDT)
Message-ID: <477963.52849.qm@web32605.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web32605.mail.mud.yahoo.com ([68.142.207.232]:24862 "HELO
	web32605.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751924AbZJZEaF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 00:30:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Matt, Eric, Benny,

Sorry about the slow response to your fast replies. I think Benny is co=
rrect, the 'problem' lies in the fact that we were using a VLAN ID of 0=
, without knowing its special significance. User error.

I tested it with other VLAN id's (>0) and it appears to work fine. We a=
re not entirely sure we understand=A0 why it used to work with VLAN ID =
0 on the Broadcom chips and still does with a number of different cards=
 (with >2.6.27 kernels).=A0 What is the 'correct' behaviour for this in=
correct usage ? When a PC returns the ARP response to the machine with =
the BroadCom card, it will have the destination address of the VLAN dev=
ice, but presumably the VLAN ID tag set to zero.=A0 Hmmm. I can live wi=
th not knowing the answer I guess.


Thanks again,

Gertjan



=20

--- On Fri, 10/23/09, Matt Carlson <mcarlson@broadcom.com> wrote:

> From: Matt Carlson <mcarlson@broadcom.com>
> Subject: Re: VLAN and ARP failure on tg3 drivers
> To: "Gertjan Hofman" <gertjan_hofman@yahoo.com>
> Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Date: Friday, October 23, 2009, 3:35 PM
> On Thu, Oct 22, 2009 at 09:52:42PM
> -0700, Gertjan Hofman wrote:
> > Dear Kernel developers,
> >=20
> > A couple of weeks ago we tried to migrate from a
> 2.6.24? kernel to a 2.6.29 kernel and noticed our VLAN
> application no longer works.? The problem is easy to
> replicate:
> >=20
> > 1. connect 2 PC's with a cross-over cable
> > 2. set up a fixed IP address to both PC's? (say
> 192.168.0.[1,2])
> > 3. create a vlan:? vconfig? add eth0 0.
> > 4. set IP addresses on the VLAN devices? (say
> 192.168.1.[1,2])
> > 5. try ping one machine from the other.
> >=20
> > I tried to dig into the problem by using un-patched
> kernel.org kernels with Ubuntu .config files.? Kernels up to
> 2.6.26 work fine, kernels after and including 2.6.27 fail.
> The problem is that ARP messages are being dropped. If the
> ARP table is updated by hand on each machine, the
> communication across the VLAN works fine.
> >=20
> > At first I thought the kernel VLAN code was the
> problem (we had an earlier issue with a regression in
> 2.6.24) but it looks like the problem is actually with the
> tg3 driver.? Our system uses Broadcom ethernet chips. I
> tried the same experiments with combination of boards that
> have Broadcom and none-Broadcom and the only time I see it
> fail is with the tg3? driver loaded.
> >=20
> > Snooping with WireShark shows that a ARP request from
> the non-Broadcom machine is seen and even answered, but
> never appears back on the network. If the Broadcom machine
> orginates the ARP message, it never arrives at the
> destination. I tried lowering the size of the MTU to 1492 as
> well as giving each VLAN device a different MAC. No deal.
> >=20
> > I tried to look at tg3 patch changes from 2.6.26 to
> 2.6.27 but I am not familiar enough with the Git system to
> extract the appropiate changes.? I am a bit surprised that I
> am not seeing any references to this on the web, the
> combination of >2.6.27 kernels, Broadcom and VLAN cant be
> that uncommon.
> >=20
> > I would be happy to provide more information and to
> try tests if any one can suggest them.
> >=20
> > Sincerely,
> >=20
> > Gertjan
>=20
> I don't see any reason why your setup should fail, but it
> doesn't hurt
> to gather more info about the problem.
>=20
> What device are you experiencing this problem with?=A0
> Is management
> firmware enabled?=A0 (`ethtool -i ethx`)
>=20
>






     =20
