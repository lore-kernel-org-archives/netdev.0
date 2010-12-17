From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA drivers
Date: Fri, 17 Dec 2010 01:51:15 -0800
Message-ID: <AANLkTindp3QAfPJdE-8RCUH+gnoshDtE95d_RReGBTi6@mail.gmail.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	<alpine.LNX.2.01.1012161253560.3000@obet.zrqbmnf.qr>
	<alpine.LNX.2.01.1012161321500.6484@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paul.gortmaker@windriver.com, Joe Perches <joe@perches.com>,
	"Maciej W. Rozycki" <macro@linux-mips.org>, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36175 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab0LQJvP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 04:51:15 -0500
Received: by iyi12 with SMTP id 12so310185iyi.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 01:51:15 -0800 (PST)
In-Reply-To: <alpine.LNX.2.01.1012161321500.6484@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 04:22, Jan Engelhardt <jengelh@medozas.de> wrot=
e:
> [adding missing cc:netdev]
>
>
> A few comments, since I have just been made aware of the Netconf slid=
es,
>
>
> Paul Gortmaker wrote:
>>
>>If in fact this series gets agreement, I'm figuring it makes sense to
>>have it go in either at the beginning of a dev cycle, or at the very
>>end
>
> I think I have seen git properly coping with renames, if your and oth=
er
> developers' branches are git-merged (patchwise application of course
> leads to rejects).
>
>
>>classifying drivers according to the physical layer they support or i=
f
>>multiple are, such as with the Ethernet that is backwards compatible,
>>the newest variation they do?
>
> Above all I would probably like to see
>
> - getting rid of the "1000 Mbit" and "10000 Mbit" submenus. jme.ko fo=
r
> example is put under 1000 Mbit, but the jme chip I have ("197b:0260 (=
rev
> 02) JMicron Technology Corp. JMC260 PCI Express Fast Ethernet
> Controller") does not do 1000.

Organization of the Kconfig menus/sub-menus is also goal in this
organization of /drivers/net.  I like the 10/100, 1000, and 10GbE
sub-menus, but if we find that there are issues with drivers that
support hardware in more than one category, then we should look at the
best way to handle those drivers or organization of the Ethernet
sub-menus.

>
> - getting rid of CONFIG_NET_PCI and move dependencies to individual
> driver config options. It looks odd that only drivers from the 10/100
> Mbit category=C2=A0=E2=80=94 and then, not even all=C2=A0=E2=80=94 de=
pend on this. Of course you
> probably won't see Gbit adapters for ISA, but SUN, 3com, HP cards are
> also available on PCI.

Agreed, this is fixed in some of the preliminary patches that Joe and
I have been working on.

>
> Jeff Kirsher puts forward in:
>>
>>http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>>
>>Create /drivers/net/sw for vlan, 8021q, bonding, bridging, etc driver=
s
>
> That does not seem too nice. Currently, bridge is at net/bridge/, and
> moving it into drivers/net/sw/bridge/ is just elongating the path nam=
e
> for a rename that is.. a bit disputable as far as I read the thread.

The reasoning behind this idea was that we are trying to organize
/drivers/net so that we have /drivers/net/<L2 technologies> for
example:
/drivers/net/appletalk
/drivers/net/arcnet
/drivers/net/ethernet
/drivers/net/tokenring
/drivers/net/wimax
/drivers/net/wireless

Stack drivers like vlan, bonding, bridging do not fall into this and
so we thought it best to create a /drivers/net/sw directory for stack
drivers like this.  For now, we planned on keeping stack drivers in
/drivers/net/.  IMHO I still think that moving stack drivers to
/drivers/net/sw is still a good idea but it does not have to happen
right away.

>
> What is in net/, leave it there for now.
> drivers/net/ethernet/, I am fine with.

Most of the drivers in /drivers/net are Ethernet drivers and should
reside in /drivers/net/ethernet (if they are Ethernet drivers) when
the directory structure exists.

--=20
Cheers,
Jeff
