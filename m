From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xtables: fix reentrancy
Date: Fri, 18 Mar 2011 11:50:27 +0100
Message-ID: <1300445427.2888.23.camel@edumazet-laptop>
References: <1300302005.3202.23.camel@edumazet-laptop>
	 <20110316.131648.15245216.davem@davemloft.net>
	 <1300358140.3133.117.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1103171231220.21558@ask.diku.dk>
	 <1300362323.3133.195.camel@edumazet-laptop>
	 <1300367841.6315.9.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1103181113040.21558@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45021 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1CRKud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 06:50:33 -0400
In-Reply-To: <Pine.LNX.4.64.1103181113040.21558@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 11:27 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :

> I have actually enabled PREEMPTion, am I in trouble then?
>=20

Well, to get problem on localy generated trafic (as all forwarding is
done from softirq handler), you'll need a malicious -j RETURN in OUTPUT
hook (in the OUTPUT chain, not a called one)

Also, even for localy generated trafic, I guess most callers block BH
before calling ipt_do_table() anyway...

> I have modified the .config I got from you, quite a lot, during my=20
> attempts to find the CCISS/HPSA problem.
>=20
> Which reminds me that I needed to enable, the follwing config options=
,=20
> (which your config didn't have):
>   CONFIG_PCIEASPM=3Dy
>   CONFIG_X86_X2APIC=3Dy
>=20
> In order to get rid of a PCI warning:
>   NMI: PCI system error (SERR) for reason b1 on CPU 0.
>   Dazed and confused, but trying to continue
>=20
> The system worked fine, and you might not see this issue on your G6=20
> servers, as its most likely BIOS related (my server is a HP DL370 G6)=
=2E
>=20

Mine is ProLiant BL460c G6

> FYI: Operations have deployed the kernel on prod server this morning.

Okay, lets pray ;)



