From: Aurelien Jarno <aurelien@aurel32.net>
Subject: Re: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
Date: Mon, 31 Jan 2011 12:45:58 +0100
Message-ID: <20110131114558.GA28303@volta.aurel32.net>
References: <20100530010219.GA20368@volta.aurel32.net>
 <8DD2590731AB5D4C9DBF71A877482A900118D29D0A@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.126.93]:45553 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab1AaLp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 06:45:57 -0500
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A900118D29D0A@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jun 01, 2010 at 04:33:27PM -0700, Allan, Bruce W wrote:
> I will look into this in the next couple days.
>=20
> -----Original Message-----
> From: Aurelien Jarno [mailto:aurelien@aurel32.net]=20
> Sent: Saturday, May 29, 2010 6:02 PM
> To: Allan, Bruce W; Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org
> Subject: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40=
ab
>=20
> Hi,
>=20
> I have recently upgrade my kernel, and found that Intel AMT support i=
s
> not working anymore as expected. I have configured IAMT so that is=20
> always available, even when the machine is off ("Desktop: ON in S0, S=
3,
> S4-5").
>=20
> On recent kernels, IAMT support does not work after the machine has=20
> been powered-off. Even worse, it also goes into this state when I try
> to reboot it.
>=20
> I have done a bisect and got this commit:
>=20
> |=A0commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
> | Author: Bruce Allan <bruce.w.allan@intel.com>
> | Date:   Fri Aug 14 14:35:33 2009 +0000
> |=20
> |     e1000e: WoL does not work on 82577/82578 with manageability ena=
bled
> |    =20
> |     With manageability (Intel AMT) enabled via BIOS, PHY wakeup doe=
s not get
> |     configured on newer parts which use PHY wakeup vs. MAC wakeup w=
hich causes
> |=A0    WoL to not work.  The driver should configure PHY wakeup whet=
her or not
> |     manageability is enabled.
> |    =20
> |     Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> |     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> |     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> I have tried to revert it on recent kernels (2.6.34), and IAMT is the=
n
> working as expected. My machine is using a Gigabyte EQ45M-S2 motherbo=
ard
> with an 82567LM-3 ethernet chip (8086:10de), that is a different mode=
l
> than the one of the original problem.
>=20
> I do wonder if the changes in the patch should not only be done on so=
me=20
> chip models, and I will appreciate any help in fixing this issue.
>=20

Just a short mail to say this problem is still present in 2.6.38-rc2.
The same solution still applies, that is reverting the above commit.
Note that reverting the first hunk only is enough to get it working
again.

--=20
Aurelien Jarno                          GPG: 1024D/F1BCDB73
aurelien@aurel32.net                 http://www.aurel32.net
