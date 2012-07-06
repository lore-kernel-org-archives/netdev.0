From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Sat, 7 Jul 2012 00:11:02 +0200
Message-ID: <20120706221102.GA14276@electric-eye.fr.zoreil.com>
References: <20120706200146.GA11931@electric-eye.fr.zoreil.com> <2138981415.303377.1341610005571.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Nancy Lin <nancy.lin@smsc.com>
To: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54532 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab2GFWWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:22:48 -0400
Content-Disposition: inline
In-Reply-To: <2138981415.303377.1341610005571.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=C3=89meric Vigier <emeric.vigier@savoirfairelinux.com> :
[...]
> Yes, there are 16 bits wide according to smsc95xx.h.
> But other smsc drivers define 32bit wide PHY regs. I made myself beli=
eve
> that smsc would use the same PHY for each ethernet chip.

SMSC people would surely answer before I find the relevant datasheet.

Anyway the PHY registers are accessed indirectly through the MII_{ADDR,=
 DATA}
registers and MII_DATA r/w mask is limited to the lower 16 bits.

> So would something like s/32 * sizeof(u32)/PHY_SPECIAL * sizeof(u16)/=
 solve the issue here?

You would have to pack data[] as well. Or use u16 *.

> Concerning the ioctl, I found ethtool much easier to use. And I belie=
ve
> smsc9514 is a very popular chipset, so this could help others debuggi=
ng it.

# mii-tool -vv e1000
Using SIOCGMIIPHY=3D0x8947
e1000: no autonegotiation, 10baseT-HD, link ok
  registers for MII PHY 0:=20
    1140 796d 0141 0c30 0de1 0021 0004 0000
    0000 0200 0000 0000 0000 0000 0000 3000
    0000 0000 0000 0000 0174 0000 0000 0000
    4100 0000 000d 000f 0000 0000 0000 0000
  product info: vendor 00:50:43, model 3 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10bas=
eT-HD
  advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10bas=
eT-HD flow-control
  link partner: 10baseT-HD

It is not that bad for the first 32 PHY registers.

[...]
> Do you mean LTT? I am not familiar with it, I should have a look.

Documentation/trace/ftrace.txt

[...]
> I should change that in previous "for" loop as well I suppose?

You may.

--=20
Ueimor
