From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: send IPIs ASAP
Date: Tue, 20 Apr 2010 17:17:26 +0800
Message-ID: <j2l412e6f7f1004200217h904cf469le35387c350d4d1a2@mail.gmail.com>
References: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
	<g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
	<1271742351.3845.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:43648 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065Ab0DTJRq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 05:17:46 -0400
Received: by iwn35 with SMTP id 35so2936013iwn.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 02:17:46 -0700 (PDT)
In-Reply-To: <1271742351.3845.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 1:45 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 19 avril 2010 =C3=A0 22:15 -0700, Tom Herbert a =C3=A9crit :
>> On Mon, Apr 19, 2010 at 9:08 PM, Changli Gao <xiaosuo@gmail.com> wro=
te:
>> > rps: send IPIs ASAP
>> >
>> > In order to reduce latency, we'd better send IPIs ASAP to schedule=
 the
>> > corresponding NAPIs.
>> >
>> A design point of RPS is that we generate at most one IPI per CPU pe=
r
>> device interrupt, which at least offers some predictable coalescing.
>> With your changes, we would get at most one IPI per packet-- that
>> could represent a lot more of them. =C2=A0Did you test this to see w=
hat the
>> impact is in this regard?
>>
>
> I agree with you Tom. Coalescing IPI is probably better.
>
> If the receiver CPU got a single packet in its RX handling, latency w=
ill
> be the same anyway.

I did the "ping -f" test again, and found that the differences of RTT
I got before were noises. It seems your "shortcut net_rps_action()"
patch eliminates the differences.

>
> If the receiver CPU got many packets, chance is high we are in a stre=
ss
> situation, and coalescing is a win in this case.
>
> I am currently testing a patch to call net_rps_action() at the beginn=
ing
> of process_backlog() (if we have a non null ipi_rps_list pointer)
>
> Will post a patch with bench results
>

It sounds like a better idea.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
