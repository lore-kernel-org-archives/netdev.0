From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive
 open side
Date: Wed, 8 Jun 2011 20:39:32 -0700
Message-ID: <BANLkTi=HZM3pPt9x6Rnb5juy-C09-BB7qiYu57Zc13qdR+qwjQ@mail.gmail.com>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
	<1307550654.3057.70.camel@edumazet-laptop>
	<BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
	<BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
	<1307576361.3980.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:2332 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab1FIDjf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 23:39:35 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p593dYmc004346
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 20:39:34 -0700
Received: from yxp4 (yxp4.prod.google.com [10.190.4.196])
	by hpaq12.eem.corp.google.com with ESMTP id p593cq7h008150
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 20:39:33 -0700
Received: by yxp4 with SMTP id 4so745900yxp.26
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 20:39:33 -0700 (PDT)
In-Reply-To: <1307576361.3980.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2011 at 4:39 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 08 juin 2011 =E0 15:26 -0700, Jerry Chu a =E9crit :
>> Eric,
>>
>> It just occurred to me now that initRTO is being reduced, both TCP_S=
YN_RETRIES
>> and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) to =
meet the
>> 3 minutes R2 requirement per RFC1122.
>>
>> If you agree, I will submit another patch.
>>
>
> Good catch, but no RFC lowered yet this 3 minutes requirement ?

Not that I know of. BTW, I'm not as nearly concerned about RFC complian=
ce
as what's the "right thing" to do, e.g., if apps have some expectation =
on
how long, e.g., a connect() call will persistent before ETIMEOUT...

With exponential backoff, initRTO of 3secs and 5 retries will last 189 =
secs
before ETIMEOUT. Setting initRTO to 1sec reduces this time to 63 secs.
Guess it's still more than one minute so it's not too bad. Now I don't =
think
it's a good idea to raise retries to 7 or 247 secs, which seems too lon=
g (more
than 4 minutes) just to be RFC compliant. Raising retries to 6 or allow=
ing
127 secs might be more reasonable though.

Thought?

Jerry
