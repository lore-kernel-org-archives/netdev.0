From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Thu, 19 May 2011 19:01:53 -0700
Message-ID: <BANLkTinBm0C4ZVE=M98AtsF--y03p4Hafg@mail.gmail.com>
References: <1305619677.2850.11.camel@edumazet-laptop>
	<1305715384-81716-1-git-send-email-tsunanet@gmail.com>
	<20110518.152653.1486764697527722925.davem@davemloft.net>
	<BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 12:40 PM, tsuna <tsunanet@gmail.com> wrote:
> On Wed, May 18, 2011 at 12:26 PM, David Miller <davem@davemloft.net> =
wrote:
>> If you read the ietf draft that reduces the initial RTO down to 1
>> second, it states that if we take a timeout during the initial
>> connection handshake then we have to revert the RTO back up to 3
>> seconds.
>>
>> This fallback logic conflicts with being able to only change the
>> initial RTO via sysctl, I think. =A0Because there are actually two
>> values at stake and they depend upon eachother, the initial RTO and
>> the value we fallback to on initial handshake retransmissions.
>>
>> So I'd rather get a patch that implements the 1 second initial
>> RTO with the 3 second fallback on SYN retransmit, than this patch.
>>
>> We already have too many knobs.
>
> I was hoping this knob would be accepted because this is such an
> important issue that it even warrants an IETF draft to attempt to
> change the standard. =A0I'm not sure how long it will take for this
> draft to be accepted and then implemented, so I thought adding this
> simple knob today would really help in the future.

As one of the co-authors of rfc2988bis I was planning to provide a patc=
h
as soon as the draft gets approved but it looks like you have beaten
me to it :)

Personally I'm in favor of a knob too. We at Google has added such a
knob for years.

Jerry

>
> Plus, should the draft be accepted, this knob will still be just as
> useful (e.g. to revert back to today's behavior), and people might
> want to consider adding another knob for the fallback initRTO (this i=
s
> debatable). =A0I don't believe this knob conflicts with the proposed
> change to the standard, it actually goes along with it pretty well an=
d
> helps us prepare better for this upcoming change.
>
> I agree that there are too many knobs, and I hate feature creep too,
> but I've found many of these knobs to be really useful, and the degre=
e
> to which Linux's TCP stack can be tuned is part of what makes it so
> versatile.
>
> --
> Benoit "tsuna" Sigoure
> Software Engineer @ www.StumbleUpon.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
