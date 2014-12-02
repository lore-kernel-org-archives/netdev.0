From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 2 Dec 2014 09:31:20 -0800
Message-ID: <CAA93jw4H4MBMgP-gpF6R35RZhYnpZ78r5RQ=6GT2TtGfuECadQ@mail.gmail.com>
References: <20141202071304.GA22512@1wt.eu>
	<1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<547DF2EA.2020908@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Willy Tarreau <w@1wt.eu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:57038 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbaLBRbV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:31:21 -0500
Received: by mail-ob0-f172.google.com with SMTP id wn1so10245668obc.31
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 09:31:20 -0800 (PST)
In-Reply-To: <547DF2EA.2020908@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2014 at 9:12 AM, Ezequiel Garcia
<ezequiel.garcia@free-electrons.com> wrote:
> Eric,
>
> On 12/02/2014 09:18 AM, Eric Dumazet wrote:
> [..]
>>
>> I am surprised TCP even worked correctly with this problem.
>>
>> I highly suggest BQL for this driver, now this issue is fixed.
>>
>
> Implementing BQL for the mvneta driver was something I wanted to do a
> while ago, but you explained that these kind drivers (i.e. those with
> software TSO) didn't need BQL, because the latency that resulted from
> the ring was too small.
>
> Quoting (http://www.spinics.net/lists/netdev/msg284439.html):
> ""
> Note that a full size TSO packet (44 or 45 MSS) requires about 88 or =
90
> descriptors.
>
> So I do not think BQL is really needed, because a 512 slots TX ring w=
ont
> add a big latency : About 5 ms max.

at a gigabit.

Wildly variable with pause frames. And: 50ms at 100mbit. 500ms at 10mbi=
t.

Secondly, why accept any latency in the driver when you can get it well=
 below
2ms in most circumstances with a couple lines of BQL code?

>
> BQL is generally nice for NIC supporting hardware TSO, where a 64KB T=
SO
> packet consumes 3 or 4 descriptors.

BQL is nice at any speed, and darn useful at lower speeds,
as well.

>
> Also note that TCP Small Queues should limit TX ring occupancy of a
> single bulk flow anyway.

We only do one upload or one download at a time on our systems,
followed by a ping measurement... never do more than one flow
at the same time, right?


> ""
>
> Maybe I misunderstood something?

Try it, test it, you'll like it.

> --
> Ezequiel Garc=C3=ADa, Free Electrons
> Embedded Linux, Kernel and Android Engineering
> http://free-electrons.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
