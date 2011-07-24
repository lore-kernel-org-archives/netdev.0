From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sun, 24 Jul 2011 10:35:58 +0200
Message-ID: <4E2BD96E.4090101@gmail.com>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net> <20110722092159.GA20722@gondor.apana.org.au> <4E2ADB39.9070409@gmail.com> <20110723152724.GA11028@gondor.apana.org.au> <20110723093743.7c90b78f@nehalam.ftrdhcpuser.net> <20110724001816.GA14051@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, jbohac@suse.cz,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35798 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab1GXIgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 04:36:03 -0400
Received: by wwg11 with SMTP id 11so677589wwg.1
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2011 01:36:01 -0700 (PDT)
In-Reply-To: <20110724001816.GA14051@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2011 02:18, Herbert Xu a =E9crit :
> On Sat, Jul 23, 2011 at 09:37:43AM -0700, Stephen Hemminger wrote:
>>
>> Would it be possible to do live migration without dropping carrier
>> or setting interface down?
>
> I think LM uses the same mechanism as suspend and resume so whatever
> happens in one case will happen in the other case as well.

So we need to distinguish between two kind of link events:

1/ Really having the link goes down then up. This should trigger a rene=
gotiation.

2/ Having the system suspend then resume :
2a/ This should trigger link down/link up events to force a renegotiati=
on, for normal suspend/resume=20
where the network might have changed between suspend and resume.
2/ This should *not* trigger link down/link up events to avoid a renego=
tiation (for live migration)=20
because it is assumed that the network didn't change while suspended.

Can't we allow the user to set a global "link-down-link-up-timeout" and=
 only force a renegotiation=20
if the time between link down and link up events is longer than this ti=
meout? Normal user would set=20
this timeout close to 0 (default value). Live migration user would set =
this timeout to about twice=20
the time it normally takes to do a live migration. That way, in a VM en=
vironment, if the=20
suspend/resume cycle happens to take far more than a normal live migrat=
ion time, the kernel would=20
renegotiate, which sounds reasonable, from my point of view.

Does this make sense?

	Nicolas.
