From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 22:13:07 +0800
Message-ID: <AANLkTimiMRL+DM+XzxLoK_zdHv_KGhbxyBRCazStpZ6c@mail.gmail.com>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
 <b2c34db84e88366e465af590900ae3db@localhost> <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
 <1290153111.29509.2.camel@edumazet-laptop> <1290153398.29509.7.camel@edumazet-laptop>
 <AANLkTikxUnj-_ov_5o6zDffv2M8J8JJg-M5HS6dr4s=a@mail.gmail.com>
 <1290160467.3034.33.camel@edumazet-laptop> <1290165472.3034.109.camel@edumazet-laptop>
 <AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
 <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com> <1290172607.3034.124.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37495 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab0KSONb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 09:13:31 -0500
Received: by fxm13 with SMTP id 13so688748fxm.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 06:13:29 -0800 (PST)
In-Reply-To: <1290172607.3034.124.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 19, 2010 at 9:16 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 19 novembre 2010 =E0 20:57 +0800, Changli Gao a =E9crit :
>> On Fri, Nov 19, 2010 at 8:32 PM, Changli Gao <xiaosuo@gmail.com> wro=
te:
>> >
>> > you missed the users of sk_run_filter in directory dev/.
>> >
>>
>> Sorry, the directory is drivers/.
>>
>>
>
> You're right, thanks !
>
> [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
>
> Remove pc variable to avoid arithmetic to compute fentry at each filt=
er
> instruction. Jumps directly manipulate fentry pointer.
>
> As the last instruction of filter[] is guaranteed to be a RETURN, and
> all jumps are before the last instruction, we dont need to check filt=
er
> bounds (number of instructions in filter array) at each iteration, so=
 we
> remove it from sk_run_filter() params.
>
> On x86_32 remove f_k var introduced in commit 57fe93b374a6b871
> (filter: make sure filters dont read uninitialized memory)
>
> Note : We could use a CONFIG_ARCH_HAS_{FEW|MANY}_REGISTERS in order t=
o
> avoid too many ifdefs in this code.
>
> This helps compiler to use cpu registers to hold fentry and A
> accumulator.
>
> On x86_32, this saves 401 bytes, and more important, sk_run_filter()
> runs much faster because less register pressure (One less conditional
> branch per BPF instruction)
>
> # size net/core/filter.o net/core/filter_pre.o
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> =A0 2948 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A02948 =A0 =A0 b84 net/core=
/filter.o
> =A0 3349 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A03349 =A0 =A0 d15 net/core=
/filter_pre.o
>
> on x86_64 :
> # size net/core/filter.o net/core/filter_pre.o
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> =A0 5173 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A05173 =A0 =A01435 net/core=
/filter.o
> =A0 5224 =A0 =A0 =A0 0 =A0 =A0 =A0 0 =A0 =A05224 =A0 =A01468 net/core=
/filter_pre.o
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Changli Gao <xiaosuo@gmail.com>
> Cc: Hagen Paul Pfeifer <hagen@jauu.net>

Acked-by: Changli Gao <xiaosuo@gmail.com>

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
