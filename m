From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Mon, 11 Jan 2016 18:27:09 +0000
Message-ID: <5693F3FD.4030804@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C9B.3090408@solarflare.com>
 <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
 <568FD844.3020101@solarflare.com>
 <CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
 <CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
 <CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
 <CAEh+42itZQDiQMrk_rf9LLgeYD=WDa2DMPq8u-9VtUf-eCoQ2Q@mail.gmail.com>
 <CALx6S35sBDydNEmJwcBfKnbVhFdtEk8dkwjWsVRhrEHOLn4jTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Tom Herbert <tom@herbertland.com>, Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:56320 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761296AbcAKS1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:27:20 -0500
In-Reply-To: <CALx6S35sBDydNEmJwcBfKnbVhFdtEk8dkwjWsVRhrEHOLn4jTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 17:55, Tom Herbert wrote:
> On Mon, Jan 11, 2016 at 9:24 AM, Jesse Gross <jesse@kernel.org> wrote:
>> It's hard to say what other types of endpoints might do if they
>> receive a VXLAN packet with a checksum set and, of course, there are
>> other protocols that don't specify that received UDP checksums can be
>> ignored.
>>
> RFC1122 is very clear on the subject of UDP checksums:
>
> "If a UDP datagram is received with a checksum that is non- zero and
> invalid, UDP MUST silently discard the datagram."
>
> So if a VXLAN receiver accepts a UDP packet without checking a
> non-zero UDP checksum for validity they are breaking the UDP protocol.
> If they blow up because they don't expect to receive non-zero
> checksums that is entirely their problem.
More to the point, RFC7348 says that if the outer checksum isvalid, the
 receiver MUST accept it.
"If the decapsulating destination chooses not to perform the verification,
 or performs it successfully, the packet MUST be accepted for decapsulation."
Therefore, if they blow up because they don't expect to receive non-zero
 checksums, they're not compliant with the spec.
On the other hand, there is always 'be conservative in what you emit'... how
 far should you go to interoperate with broken implementations.
On the gripping hand, I suspect RFC7348 only recommends against outer csums
 in the first place because the authors believed it was expensive.

-ed
