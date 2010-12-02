From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install time
Date: Thu, 2 Dec 2010 18:59:26 +0800
Message-ID: <AANLkTinZpie1cyorgfc1hcXSvS3vX2Recu_e0H5B_cpj@mail.gmail.com>
References: <1291227893.2856.1039.camel@edumazet-laptop> <20101201.104450.183053379.davem@davemloft.net>
 <1291232937.2856.1042.camel@edumazet-laptop> <20101201.122312.229751364.davem@davemloft.net>
 <1291236342.2856.1057.camel@edumazet-laptop> <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
 <1291272384.2856.1074.camel@edumazet-laptop> <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
 <1291280000.2871.16.camel@edumazet-laptop> <1291280402.2871.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46141 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab0LBK7s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 05:59:48 -0500
Received: by fxm20 with SMTP id 20so999219fxm.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 02:59:47 -0800 (PST)
In-Reply-To: <1291280402.2871.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 2, 2010 at 5:00 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 02 d=E9cembre 2010 =E0 09:53 +0100, Eric Dumazet a =E9crit :
>> Le jeudi 02 d=E9cembre 2010 =E0 16:11 +0800, Changli Gao a =E9crit :
>>
>> > It seems correct to me now.
>> >
>> > Acked-by: Changli Gao <xiaosuo@gmail.com>
>> >
>>
>> Thanks for reviewing Changli.
>>
>> Now I am thinking about not denying the filter installation, but cha=
nge
>> the problematic LOAD M(1) =A0and LOADX M(1) =A0by LOADI #0 (BPF_S_LD=
_IMM
>> K=3D0) and LOADIX #0 (BPF_S_LDX_IMM K=3D0)
>>
>> (ie pretend the value of memory is 0, not a random value taken from
>> stack)
>>
>>
>> [PATCH v3 net-next-2.6] filter: add a security check at install time
>
> Doh, I sent a version with old (V1) check_load_and_stores() name, her=
e
> is a V4 with shorter name check_loads() as mentioned in changelog.
>
> Sorry for the mess.
>
> [PATCH v4 net-next-2.6] filter: add a security check at install time
>
> We added some security checks in commit 57fe93b374a6
> (filter: make sure filters dont read uninitialized memory) to close a
> potential leak of kernel information to user.
>
> This added a potential extra cost at run time, while we can perform a
> check of the filter itself, to make sure a malicious user doesnt try =
to
> abuse us.
>
> This patch adds a check_loads() function, whole unique purpose is to
> make this check, allocating a temporary array of mask. We scan the
> filter and propagate a bitmask information, telling us if a load M(K)=
 is
> allowed because a previous store M(K) is guaranteed.
>
> If we detect a problematic load M(K), we replace it by a load of
> immediate value 0
>

Since RAM of BPF isn't initialized to zero and this kind of
instruction sequences is invalid, I think we'd better return -EINVAL
instead of mangling the instruction silently. I prefer V2.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
