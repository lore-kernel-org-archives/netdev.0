From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 11:17:15 +0100
Message-ID: <4984252B.8080508@cosmosbay.com>
References: <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net> <49841E8C.60401@cosmosbay.com> <20090131095640.GA29099@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52295 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbZAaKRo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 05:17:44 -0500
In-Reply-To: <20090131095640.GA29099@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Sat, Jan 31, 2009 at 10:49:00AM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>> It appears you are always right, I have nothing to say then.
>>
>> Stupid I am.
>>
>> I vote for plain revert of your initial patch, since you are anaware
>> of performance problems it introduces. Then, probably nobody cares
>> of my complaints, so dont worry.
>=20
> Eric, do not get it soo personally :) After all it is only a matter o=
f
> how we enjoy the process and have fun with the development.
>=20
> Really, I appreciate your work and help, and likely this
> misunderstanding happened because of a bad mix of the original bug an=
d
> this performance implication. Original bug has really nothing with wh=
at
> we discuss here. And while the performance problem with bound sockets
> creation may be visible, I did not observe it, while the idea
> implemented with this approach shows up clearly in the graph I posted=
=2E
> So I vote by both hands to further improve it by moving things around=
 so
> that there would be no unneded cache flushes during update of this
> field.
>=20

OK OK, as I said, dont worry, it was not a strong feeling from me, only
a litle bit upset, thats all.

We only need to know if the *fix* is solving Stephen problem

About performance effects of careful variable placement and percpu coun=
ter
strategy you might consult as an example :

http://lkml.indiana.edu/hypermail/linux/kernel/0812.1/01624.html

Now, with these patches applied, try to see effect of your new bsockets=
 field
on a network workload doing lot of socket bind()/unbind() calls...

With current kernels, you probably wont notice because of inode/dcache =
hot
cache lines, but it might change eventually...


