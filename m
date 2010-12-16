From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Thu, 16 Dec 2010 13:22:13 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012161321500.6484@obet.zrqbmnf.qr>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com> <alpine.LNX.2.01.1012161253560.3000@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:46486 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab0LPMWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 07:22:15 -0500
In-Reply-To: <alpine.LNX.2.01.1012161253560.3000@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding missing cc:netdev]


A few comments, since I have just been made aware of the Netconf slides=
,


Paul Gortmaker wrote:
>
>If in fact this series gets agreement, I'm figuring it makes sense to=20
>have it go in either at the beginning of a dev cycle, or at the very=20
>end

I think I have seen git properly coping with renames, if your and other=
=20
developers' branches are git-merged (patchwise application of course=20
leads to rejects).


>classifying drivers according to the physical layer they support or if=
=20
>multiple are, such as with the Ethernet that is backwards compatible,=20
>the newest variation they do?

Above all I would probably like to see

- getting rid of the "1000 Mbit" and "10000 Mbit" submenus. jme.ko for=20
example is put under 1000 Mbit, but the jme chip I have ("197b:0260 (re=
v=20
02) JMicron Technology Corp. JMC260 PCI Express Fast Ethernet=20
Controller") does not do 1000.

- getting rid of CONFIG_NET_PCI and move dependencies to individual=20
driver config options. It looks odd that only drivers from the 10/100=20
Mbit category=C2=A0=E2=80=94 and then, not even all=C2=A0=E2=80=94 depe=
nd on this. Of course you=20
probably won't see Gbit adapters for ISA, but SUN, 3com, HP cards are=20
also available on PCI.


Jeff Kirsher puts forward in:
>
>http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>
>Create /drivers/net/sw for vlan, 8021q, bonding, bridging, etc drivers

That does not seem too nice. Currently, bridge is at net/bridge/, and=20
moving it into drivers/net/sw/bridge/ is just elongating the path name=20
for a rename that is.. a bit disputable as far as I read the thread.

What is in net/, leave it there for now.
drivers/net/ethernet/, I am fine with.
