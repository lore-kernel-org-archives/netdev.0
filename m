From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 17:12:23 -0700
Message-ID: <CAB_+Fg6vPX9L5+uzKAop-92dtgMYuDCd-DnUk534RAksDd6uMg@mail.gmail.com>
References: <4E82C0DD.6010304@intel.com>
	<alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi>
	<4E82E0EE.1050600@intel.com>
	<4E82E5B5.1050206@intel.com>
	<alpine.DEB.2.00.1109281226480.21709@wel-95.cs.helsinki.fi>
	<4E82FAD6.1010708@intel.com>
	<alpine.DEB.2.00.1109281418280.21709@wel-95.cs.helsinki.fi>
	<CAB_+Fg5ZzC43XcVjoByepZvA4Mknu6PkRWzpUju+KAQnoMb8JQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:44076 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab1I2AMZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 20:12:25 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8T0CPOH008692
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:12:25 -0700
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by wpaz33.hot.corp.google.com with ESMTP id p8T0CNpA015231
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:12:24 -0700
Received: by gyf2 with SMTP id 2so69959gyf.13
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2011 17:12:23 -0700 (PDT)
In-Reply-To: <CAB_+Fg5ZzC43XcVjoByepZvA4Mknu6PkRWzpUju+KAQnoMb8JQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually don't bother about my question. Your patch is correct. I
convinced myself that it's taking care of diff. cases correctly.

Nandita

On Wed, Sep 28, 2011 at 5:06 PM, Nandita Dukkipati <nanditad@google.com=
> wrote:
> Could you please clarify this case for me-
>
> skb =3D=3D tp->lost_skb_hint
> If skb is sacked, doesn't tcp_mark_head_lost() already increment
> lost_cnt_hint, in which case you won't need to do it here?
>
> Nandita
>
> On Wed, Sep 28, 2011 at 4:29 AM, Ilpo J=E4rvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
>> On Wed, 28 Sep 2011, Yan, Zheng wrote:
>>
>>> > But is the non-SACKed case really handled right when hint =3D=3D =
skb by the
>>> > sacktag_one. We move the seqno in between and then before(x->news=
eq,
>>> > x->newseq) check returns false?
>>> >
>>> you are right, thank you.
>>>
>>> really hope my patch is correct this time :)
>>> ---
>>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>>> index 21fab3e..a04622e 100644
>>> --- a/net/ipv4/tcp_input.c
>>> +++ b/net/ipv4/tcp_input.c
>>> @@ -1390,8 +1390,7 @@ static int tcp_shifted_skb(struct sock *sk, s=
truct sk_buff *skb,
>>> =A0 =A0 =A0 BUG_ON(!pcount);
>>>
>>> =A0 =A0 =A0 /* Tweak before seqno plays */
>>> - =A0 =A0 if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_h=
int &&
>>> - =A0 =A0 =A0 =A0 !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_S=
KB_CB(skb)->seq))
>>> + =A0 =A0 if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_h=
int =3D=3D skb)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->lost_cnt_hint +=3D pcount;
>>>
>>> =A0 =A0 =A0 TCP_SKB_CB(prev)->end_seq +=3D shifted;
>>
>> It also looks a lot nicer now and more obvious. According to my curr=
ent
>> understanding, feel free to add this once doing the proper submissio=
n with
>> Signed-off etc. (please also remove the comment too as seqnos have n=
o
>> longer any significance here):
>>
>> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>>
>> ...but it certainly wouldn't hurt if also somebody else has pair of =
eyes
>> to spare to confirm that we (both) are now in agreement what the cod=
e
>> really says.
>>
>>
>> --
>> =A0i.
>
