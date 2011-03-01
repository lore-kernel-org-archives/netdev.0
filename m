From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's
	source MAC
Date: Mon, 28 Feb 2011 21:35:25 -0500
Message-ID: <20110301023525.GK11864@gospo.rdu.redhat.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495Ab1CACfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 21:35:37 -0500
Content-Disposition: inline
In-Reply-To: <4D6C1764.1040008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 10:45:08PM +0100, Nicolas de Peslo=FCan wrote:
> Le 28/02/2011 17:32, Andy Gospodarek a =E9crit :
>> On Sat, Feb 26, 2011 at 12:08:03AM +0100, Nicolas de Peslo=FCan wrot=
e:
>>> Le 25/02/2011 23:24, Andy Gospodarek a =E9crit :
>> [...]
>>>>
>>>> I confirmed your suspicion, this breaks ARP monitoring.  I would s=
till
>>>> welcome other opinions though as I think it would be nice to fix t=
his as
>>>> low as possible.
>>>
>>> Why do you want to fix it earlier that in ndisc_recv_ns drop? Your
>>> original idea of silently dropping the frame there seems perfect to=
 me.
>>>
>>
>> Maybe it's just me, but I cannot understand why we want a bunch of e=
xtra
>> packets floating up into the stack when they may only create issues =
for
>> the recipients of these duplicate frames.
>>
>> Clearly my original patch needs to be refined so ARP monitoring stil=
l
>> works, but I would rather fix the issue there than in a higher layer=
=2E
>
> Jay explained that the current implementation should already trap tho=
se=20
> frames, on inactive slaves, in modes where inactive slaves exist. I a=
gree=20
> with him.
>
> What mode are you seeing this problem in? If the current "should drop=
"=20
> logic is leaking, then yes, we should fix it. But we currently don't =
see=20
> where it is leaking.
>

Use round-robin.  To reproduce just take the interface down and bring i=
t
back up.  You should see the messages right away.

I've been doing some more testing on a new patch and should have
something ready tomorrow.  My latest patch actually replaces the final
'return 0' with a call to a function that will return true if the sende=
r
was the device that received it.  This will hopefully prevent some of
the failures with the first patch I posted.  I'll know a bit more
tomorrow if this approach seems reasonable.

