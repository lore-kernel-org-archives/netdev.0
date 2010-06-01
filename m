From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: Re: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
Date: Tue, 1 Jun 2010 16:35:08 -0700
Message-ID: <A78C6259B11833419567082E2DC0C25601504EE527@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"'aurelien@aurel32.net'" <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45488 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756329Ab0FAXfJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 19:35:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

--
Cheers,
Jeff


-----Original Message-----
=46rom: Allan, Bruce W <bruce.w.allan@intel.com>
To: Aurelien Jarno <aurelien@aurel32.net>; Kirsher, Jeffrey T <jeffrey.=
t.kirsher@intel.com>
CC: netdev@vger.kernel.org <netdev@vger.kernel.org>
Sent: Tue Jun 01 16:33:27 2010
Subject: RE: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd=
40ab

I will look into this in the next couple days.

-----Original Message-----
=46rom: Aurelien Jarno [mailto:aurelien@aurel32.net]=20
Sent: Saturday, May 29, 2010 6:02 PM
To: Allan, Bruce W; Kirsher, Jeffrey T
Cc: netdev@vger.kernel.org
Subject: IAMT broken by commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab

Hi,

I have recently upgrade my kernel, and found that Intel AMT support is
not working anymore as expected. I have configured IAMT so that is=20
always available, even when the machine is off ("Desktop: ON in S0, S3,
S4-5").

On recent kernels, IAMT support does not work after the machine has=20
been powered-off. Even worse, it also goes into this state when I try
to reboot it.

I have done a bisect and got this commit:

|=A0commit 82776a4bcd7aa5fbcd2e6339b3ce88b727dd40ab
| Author: Bruce Allan <bruce.w.allan@intel.com>
| Date:   Fri Aug 14 14:35:33 2009 +0000
|=20
|     e1000e: WoL does not work on 82577/82578 with manageability enabl=
ed
|    =20
|     With manageability (Intel AMT) enabled via BIOS, PHY wakeup does =
not get
|     configured on newer parts which use PHY wakeup vs. MAC wakeup whi=
ch causes
|=A0    WoL to not work.  The driver should configure PHY wakeup whethe=
r or not
|     manageability is enabled.
|    =20
|     Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
|     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
|     Signed-off-by: David S. Miller <davem@davemloft.net>

I have tried to revert it on recent kernels (2.6.34), and IAMT is then
working as expected. My machine is using a Gigabyte EQ45M-S2 motherboar=
d
with an 82567LM-3 ethernet chip (8086:10de), that is a different model
than the one of the original problem.

I do wonder if the changes in the patch should not only be done on some=
=20
chip models, and I will appreciate any help in fixing this issue.

Thanks,
Aurelien


--=20
Aurelien Jarno                          GPG: 1024D/F1BCDB73
aurelien@aurel32.net                 http://www.aurel32.net
