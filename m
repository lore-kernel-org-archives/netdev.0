From: Dan Kruchinin <dkruchinin@acm.org>
Subject: Re: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Wed, 1 Sep 2010 01:00:53 +0400
Message-ID: <AANLkTikMJ2rtSNsBeaVTsVtw1ZmKpLjjyeYL=c+AgoFZ@mail.gmail.com>
References: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com>
	<20100831210101.3c059a91@leibniz>
	<4C7D5EBD.103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@osdl.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:34869 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911Ab0HaVAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 17:00:54 -0400
Received: by gwj17 with SMTP id 17so2728548gwj.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 14:00:53 -0700 (PDT)
In-Reply-To: <4C7D5EBD.103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 31, 2010 at 11:57 PM, Jarek Poplawski <jarkao2@gmail.com> w=
rote:
> Dan Kruchinin wrote, On 08/31/2010 07:01 PM:
>
>> I'm sorry it seems my email client has broken patch formating.
>> Here is properly formated one:
>> diff --git a/tc/q_tbf.c b/tc/q_tbf.c
>> index dc556fe..850e6db 100644
>> --- a/tc/q_tbf.c
>> +++ b/tc/q_tbf.c
>> @@ -178,7 +178,7 @@ static int tbf_parse_opt(struct qdisc_util *qu, =
int argc, char **argv, struct nl
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 if (opt.limit =3D=3D 0) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 double lim =3D opt.rate.=
rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 double lim =3D opt.rate.=
rate*(double)latency/TIME_UNITS_PER_SEC;
>
> The way limit is calculated here from latency suggests some safety de=
faults
> are taken wrt. the implementation, which could be omitted while setti=
ng the
> limit directly. You try to change/fix this to adhere to the documenta=
tion,
> but such a change would definitely break many user configs, so I doub=
t it's
> the right solution here. Probably you should rather think about fixin=
g the
> manual.

Thank you for comments.
The only thing that embarrasses me abut documentation fixing is that
the latency loses all its sense.
Documentation describes latency as something intuitively clear: "the
maximum amount of time a packet can sit in the TBF"
but tc implementation handles it something like: "an additional time
packet can sit int the TBF after main waiting queue which size is
equal to the burst size is completely full.". It doesn't seem to have
any sense.
Moreover, user can pass "limit" value to tc directly and if this limit
value is less than burst size then latency will be improperly
calculated(it'll have a negative value) which is not good as well.
By the way, the following descriptions of TBF algorithm are proposed
the same the manual says:
http://www.opalsoft.net/qos/DS-24.htm
ww.docum.org/docum.org/docs/other/tbf02_kw.ps

If the documentation should be fixed I'm not sure that latency can be
somehow logically described to have any sense at all.

>
> Thanks,
> Jarek P.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
W.B.R.
Dan Kruchinin
