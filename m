From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4.1 11/56] mvneta: add forgotten initialization of
 autonegotiation bits
Date: Wed, 8 Jul 2015 23:15:54 +0300
Message-ID: <559D84FA.5030203@list.ru>
References: <20150708073237.780280770@linuxfoundation.org>
 <20150708073238.389781888@linuxfoundation.org> <559D5996.5080506@list.ru>
 <20150708173655.GA16101@kroah.com> <559D6DBE.4040900@list.ru>
 <87k2uasapl.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Sebastien Rannou <mxs@sbrk.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k2uasapl.fsf@natisbad.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

08.07.2015 22:36, Arnaud Ebalard =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hi,
>
> Stas Sergeev <stsp@list.ru> writes:
>
>>>> Another problem was reported:
>>>> https://lkml.org/lkml/2015/7/8/865
>>>>
>>>> So, while the above patch is correct and fixes what
>>>> it should, the original patch has more problems to deal
>>>> with. Maybe for stable it would be better to just revert
>>>> the whole thing?
>>> No, you will have to fix this in Linus's tree, right?  So I'll take=
 the
>>> patch that you get into there when that happens, I don't want to di=
verge
>>> from what is in that tree.
>> For Linus tree I am planning a new DT property to explicitly
>> enable the inband status. I don't see any quick fix suitable for
>> -stable, and new DT property will likely not be quickly accepted.
>> If you don't want a revert, then the stable will likely have that
>> regression for quite long, that's the warning.
> I do not think the problem is to have a revert in -stable, it's more
> having in in Linus tree *first* ;-)
>
>> OTOH, the revert will remove the support for my board, so I
>> won't be able to even test it, which is also not perfect.
> ATM, the priority is more on fixing the regressions the initial patch
> caused *for existing boards*. There were at least three boards which =
got
> hit by first regression during 4.1-rc
That one is fixed, so doesn't count.

>   and a new one on the table now
> that 4.1 is out.
=46or that we don't know the impact yet.
I asked Sebastien Rannou about what HW he has
connected via sgmii link and why does he use a fixed-link.
If it is just some strange HW that does not generate the
inband status where it should, perhaps it is not such a big
deal to rush reverting it from Linus tree.

>   I understand your reluctance to revert the patch that
> made mvneta work for your custom board but it's unfair for others tha=
t
> are hit by the regressions it causes and have to spend time
> bisecting/fixing it.
I am not reluctant for a revert, I in fact _propose_ the
revert for -stable. As for mainline - yes, I'd really rather
just do a proper fix there, as there is probably not a big
deal to wait just for a little longer till the proper fix is discussed.
But since Greg have spoken against the divergence,
I am currently in an undecided state. I guess I'll code the
fix first, then will see. Hope the news will be tomorrow.

> Anyway, if you come w/ a fix, I can commit to test it on the boards I
> have.
Thanks, I'll keep you CCed.
