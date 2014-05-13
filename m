From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH net] net: filter: x86: fix JIT address randomization
Date: Tue, 13 May 2014 14:28:55 -0700
Message-ID: <53728E97.6030400@zytor.com>
References: <1400007214-3236-1-git-send-email-ast@plumgrid.com>	<1400012629.7973.61.camel@edumazet-glaptop2.roam.corp.google.com> <CAMEtUuxLbDpkxJ4fORRdsJ36vBiidBwA0SVAwvmDHEpPmhTA2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:44730 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbaEMV3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 17:29:15 -0400
In-Reply-To: <CAMEtUuxLbDpkxJ4fORRdsJ36vBiidBwA0SVAwvmDHEpPmhTA2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2014 01:34 PM, Alexei Starovoitov wrote:
>>
>> The argument of not having code ending on (or being very close of) p=
age
>> boundary seems orthogonal to this bug fix.
>=20
> Gotta pick some number... page/2 seems good enough to have
> large range for prandom() to choose and better performance.
> Another alternative is to do min(=E2=80=A6, PAGE_SIZE - sizeof(*heade=
r)),
> but that is harder to understand.
>=20

The latter is correct by construction, and thus doesn't end up with the
question "what is going on here" or has hidden failure conditions.

> Also just realized that I miscalculated the breaking point:
> "If prandom_u32() % hole selects a number >=3D 4096, then kernel will=
 crash"
> it should read: "=E2=80=A6 >=3D 4092 ..."
> since sizeof(*header) needs to be accounted for.

No, it should read PAGE_SIZE - sizeof(*header) if anything.

	-hpa
