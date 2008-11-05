From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 05 Nov 2008 10:48:55 -0800
Message-ID: <4911EA97.8080101@hp.com>
References: <20081105114900.GA18691@ioremap.net>	<20081105.035454.87914782.davem@davemloft.net>	<Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>	<20081105.040943.03609283.davem@davemloft.net>	<Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>	<20081105130405.GA26435@ioremap.net> <Pine.LNX.4.64.0811051527210.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:18796 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbYKEStF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 13:49:05 -0500
In-Reply-To: <Pine.LNX.4.64.0811051527210.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 5 Nov 2008, Evgeniy Polyakov wrote:
>=20
>=20
>>On Wed, Nov 05, 2008 at 02:25:57PM +0200, Ilpo J=E4rvinen (ilpo.jarvi=
nen@helsinki.fi) wrote:
>>
>>>The problem is that we'd need to _resegment with the next skb_ since=
 the=20
>>>mss boundary and skb boundary would basically constantly be running=20
>>>out-of-sync. That won't get done currently by anything.
>>
>>Btw, what's that wrong if there will be sub-mss frame per tso frame?
>=20
>=20
> I personally don't consider that to be a big deal... I suppose some s=
ee
> it as bad thing because of the slightly larger header vs data ratio..=
=2E
> Which is significant only if you can saturate the link (or have unbou=
nded=20
> bandwidth such as with lo), so slower links are more affected than hi=
gh=20
> speed ones...

Can't say that I tend to "like" subMSS segments out there in a bulk=20
transfer but some pseudorandom thoughts:

And the worst that would be would be one full MSS and a single byte,=20
getting us an average of (MSS+1)/2 (roughly).  It only gets better from=
=20
there (2MSS+1)/3, (3MSS+1)/4 etc etc.

Ignoring the TSO case for a moment, if there is congestion and receiver=
=20
window available and a user makes a > MSS send that isn't an integral=20
multiple of the MSS, we don't delay the last subMSS segment do we?

rick jones
