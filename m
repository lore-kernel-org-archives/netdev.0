From: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Subject: Re: Wired behaviour with IPv6 over PPP
Date: Wed, 28 May 2008 11:59:45 +0200
Message-ID: <483D2D11.9080803@plouf.fr.eu.org>
References: <48341C0B.7010003@interway.ch> <20080522014959.0f6191aa.akpm@linux-foundation.org> <48354318.60202@katalix.com> <4835C40B.60603@interway.ch> <20080524042911.GE6749@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Cramer <matthias.cramer@interway.ch>,
	James Chapman <jchapman@katalix.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-dmz-233-wednesday.dmz.nerim.net ([195.5.254.233]:55007
	"EHLO kellthuzad.dmz.nerim.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751414AbYE1KeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 06:34:22 -0400
In-Reply-To: <20080524042911.GE6749@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

Willy Tarreau a =E9crit/wrote :
> On Thu, May 22, 2008 at 09:05:47PM +0200, Matthias Cramer wrote:
>=20
>>James Chapman wrote:
>>
>>>Andrew Morton wrote:
>>>
>>>>On Wed, 21 May 2008 14:56:43 +0200 Matthias Cramer
>>>><matthias.cramer@interway.ch> wrote:
>>>>
>>>>>I have a very wired behaviour when doing IPv6 over PPPoE.
>>>>>
>>>>>The situation:
>>>>>
>>>>>A linux box connected to a DSL Modem, on the other side is a Cisco
>>>>>LNS which terminates the PPP session (actually L2TP).
>>>>>I have control over both ends.
>>>>>
>>>>>When I have net.ipv6.conf.all.forwarding set to 0 then the ppp
>>>>>Interface gets a IPv6 address from the Cisco via IP6CP.
>>>>>When I have net.ipv6.conf.all.forwarding set to 1 them the ppp
>>>>>Interface does not get an address, it has only a normal link local
>>>>>address.

AFAIK IPV6CP/PPP only allows to negotiate link local addresses. So I=20
guess the global address and default route is assigned by another=20
mechanism, maybe stateless autoconfiguration using router advertisement=
,=20
although I was not aware it could be used on a PPP link because of the=20
absence of MAC address. Enabling global forwarding=20
(net.ipv6.conf.all.forwarding=3D1) disables stateless autoconfiguration=
=20
(see ip-sysctl.txt in kernel documentation) on all interfaces. I believ=
e=20
this is consistent with the observed behaviour.

>>>>>When I start the ppp session with forwarding set to 0 I can ping o=
ut
>>>>>and there exists a default route to ppp0 , then I switch forwardin=
g to 1
>>>>>the default route disappears and therefore routing does not work a=
ny
>>>>>longer.

I have read reports about this. I guess the logic is that enabling=20
forwarding turns the box into a router, so the default route learned=20
from another router's advertisements by autoconfiguration should be=20
deleted. Even the autoconfigured global address will eventually expire.

> Well, at least it has been working for years in kernel 2.4 for me wit=
h
> pppd 2.4.2b3 to 2.4.4 (I've not upgraded my firewall to 2.6 yet). So
> it has definitely been working at some point.

What exactly has been working ?

PS : Willy, do you plan to backport the security fix for the sit module=
=20
from 2.6.25.3 into 2.4 ?
