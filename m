From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sat, 23 Jul 2011 16:31:21 +0200
Message-ID: <4E2ADB39.9070409@gmail.com>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net> <20110722092159.GA20722@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41305 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab1GWObZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 10:31:25 -0400
Received: by wwe5 with SMTP id 5so2940857wwe.1
        for <netdev@vger.kernel.org>; Sat, 23 Jul 2011 07:31:24 -0700 (PDT)
In-Reply-To: <20110722092159.GA20722@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/07/2011 11:21, Herbert Xu a =E9crit :
> On Fri, Jul 22, 2011 at 01:06:28AM -0700, David Miller wrote:
>>
>> Suspend is even more important because while we were suspended we
>> could be on the same network but the routers present and available
>> might have changed completely.
>
> Unfortunately virtual machine live migration also uses the suspend
> &  resume mechanism.  In that case we don't wish to renegotiate
> everything, since the goal is to minimise the outage window.
>
> This would suggest that putting the policy in user-space may be the
> best option.

=46or the particular situation where we use suspend/resume to migrate a=
 virtual machine, we might have=20
a kernel parameter or sysfs entry that instruct the kernel not to reneg=
otiate anything on resume.

That being said, the time to renegotiate a network setup sounds very sh=
ort, compared to the time for=20
a full suspend-migrate-resume cycle. I'm not sure VM migration would re=
ally suffer from such=20
renegotiation.

And because the local network may change while we migrate the VM (in pa=
rticular if the migration=20
happens because of some failover), I think we should enforce renegotiat=
ion on resume anyway.

	Nicolas.
