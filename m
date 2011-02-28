From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's	source
 MAC
Date: Mon, 28 Feb 2011 22:45:08 +0100
Message-ID: <4D6C1764.1040008@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56827 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab1B1Vpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 16:45:34 -0500
Received: by bwz15 with SMTP id 15so4086629bwz.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 13:45:33 -0800 (PST)
In-Reply-To: <20110228163255.GJ11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/02/2011 17:32, Andy Gospodarek a =E9crit :
> On Sat, Feb 26, 2011 at 12:08:03AM +0100, Nicolas de Peslo=FCan wrote=
:
>> Le 25/02/2011 23:24, Andy Gospodarek a =E9crit :
> [...]
>>>
>>> I confirmed your suspicion, this breaks ARP monitoring.  I would st=
ill
>>> welcome other opinions though as I think it would be nice to fix th=
is as
>>> low as possible.
>>
>> Why do you want to fix it earlier that in ndisc_recv_ns drop? Your
>> original idea of silently dropping the frame there seems perfect to =
me.
>>
>
> Maybe it's just me, but I cannot understand why we want a bunch of ex=
tra
> packets floating up into the stack when they may only create issues f=
or
> the recipients of these duplicate frames.
>
> Clearly my original patch needs to be refined so ARP monitoring still
> works, but I would rather fix the issue there than in a higher layer.

Jay explained that the current implementation should already trap those=
 frames, on inactive slaves,=20
in modes where inactive slaves exist. I agree with him.

What mode are you seeing this problem in? If the current "should drop" =
logic is leaking, then yes,=20
we should fix it. But we currently don't see where it is leaking.

	Nicolas.



