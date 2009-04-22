From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 18:57:25 +0200
Message-ID: <49EF4C75.6060604@cosmosbay.com>
References: <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <49EE2293.4090201@cosmosbay.com> <20090422073524.GA31835@elte.hu> <49EEDAF0.2010507@cosmosbay.com> <alpine.LFD.2.00.0904220806320.3101@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44110 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbZDVQ6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 12:58:55 -0400
In-Reply-To: <alpine.LFD.2.00.0904220806320.3101@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds a =E9crit :
>=20
> On Wed, 22 Apr 2009, Eric Dumazet wrote:
>> If this could be done without recursion, I am pretty sure netfilter
>> and network guys would have done it. I found Linus reaction quite
>> shocking IMHO, considering hard work done by all people on this.
>=20
> You don't _understand_ do you?
>=20
> There is a huge difference between recursive code, and a recursive lo=
ck.
>=20
> The netfilter code may need to occasionally re-enter itself. Nobody e=
ver=20
> contested _that_ part.
>=20
> What I have disagreed with the whole time is=20
>=20
>  (a) doing local ad-hoc locking primitives without any comments=20
>      what-so-ever.
>=20
>  (b) Doing them _wrong_ in many cases
>=20
>  (c) Calling the _lock_ a "recursive" lock.
>=20
> The fact that a lock works with recursion doesn't make it "recursive"=
=2E=20
> That generally has a very special meaning for locking primitives, and=
=20
> means something else.
>=20
> In contrast, a read-write lock actually has known properties, and we =
have=20
> existing locking mechanisms for those. And we call them read-write lo=
cks=20
> DESPITE THE FACT that the reading part can be done recursively.=20
>=20
> If you call a read-write lock a "recursive" lock, then you're a moron=
=2E=20
> It simply is _not_ a recursive lock. And neither is the lock you actu=
ally=20
> implemented, even though you (and Stephen) continually call it that.=20
>=20
> SO STOP CALLING IT A RECURSIVE LOCK. Look at your very own code: you =
can=20
> actually only use that lock in a recursive context in a _very_ specif=
ic=20
> place. Notice how it's only "recursive" when taken in the per-CPU con=
text,=20
> but _not_ recursive when the filter-updating code ("writer") takes it=
?
>=20
> Do you understand now? It really shouldn't be so hard for you.=20
>=20
> Naming is important. Locking is important. You did both things wrong.=
 You=20
> named your locks something incorrect and mis-leading that didn't actu=
ally=20
> describe them, and you did your own private locking code without then=
=20
> documenting what the rules for this special lock were.
>=20
> Maybe in your world that's ok. But no, in mine it's not. I've seen to=
o=20
> many damn _non-functioning_ locks to ever want to see stuff like that=
=20
> again.
>=20
>

Linus,

I actually sent *one* buggy patch, and you already gave your feedback a=
nd NACK.

=46ine

I even relayed this to Stephen suggesting him not calling this a recurs=
ive lock.
(Note how I use 'suggesting' here)

So, what do you want from me ? Should I copy 100 times :

"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
"I should not call it a recursive lock. I shall not invent new locking =
infra. I am a moron."=20
=2E..

OK done

Can we now proceed and continue ?

Thank you

