From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source MAC
Date: Mon, 28 Feb 2011 21:46:06 -0800
Message-ID: <9882.1298958366@death>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de
	 =?us-ascii?Q?=3D=3Fiso-8859-1=3FQ=3FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:37074 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682Ab1CAFqK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:46:10 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p211RQbv017705
	for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 20:27:27 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0863738C8041
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 00:46:09 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p215k9nR413958
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 00:46:09 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p215hiwV005002
	for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 22:43:45 -0700
In-reply-to: <20110301023525.GK11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Mon, Feb 28, 2011 at 10:45:08PM +0100, Nicolas de Peslo=C3=BCan wro=
te:
>> Le 28/02/2011 17:32, Andy Gospodarek a =C3=A9crit :
>>> On Sat, Feb 26, 2011 at 12:08:03AM +0100, Nicolas de Peslo=C3=BCan =
wrote:
>>>> Le 25/02/2011 23:24, Andy Gospodarek a =C3=A9crit :
>>> [...]
>>>>>
>>>>> I confirmed your suspicion, this breaks ARP monitoring.  I would =
still
>>>>> welcome other opinions though as I think it would be nice to fix =
this as
>>>>> low as possible.
>>>>
>>>> Why do you want to fix it earlier that in ndisc_recv_ns drop? Your
>>>> original idea of silently dropping the frame there seems perfect t=
o me.
>>>>
>>>
>>> Maybe it's just me, but I cannot understand why we want a bunch of =
extra
>>> packets floating up into the stack when they may only create issues=
 for
>>> the recipients of these duplicate frames.
>>>
>>> Clearly my original patch needs to be refined so ARP monitoring sti=
ll
>>> works, but I would rather fix the issue there than in a higher laye=
r.
>>
>> Jay explained that the current implementation should already trap th=
ose=20
>> frames, on inactive slaves, in modes where inactive slaves exist. I =
agree=20
>> with him.
>>
>> What mode are you seeing this problem in? If the current "should dro=
p"=20
>> logic is leaking, then yes, we should fix it. But we currently don't=
 see=20
>> where it is leaking.
>>
>
>Use round-robin.  To reproduce just take the interface down and bring =
it
>back up.  You should see the messages right away.

	What is the bond connected to?  The -rr and -xor modes are meant
to interoperate with switch ports configured for Etherchannel (or an
equivalent).  In that case, I wouldn't expect the switch to turn the
broadcasts / multicasts around and send them back out to a member of th=
e
channel group they originated from.

	If the switch isn't configured properly, then I'd expect it to
complain about MAC flapping or the like.  Unless it's an unmanaged
switch that doesn't do Etherchannel (etc), or you're setting up an
unusual topology.

>I've been doing some more testing on a new patch and should have
>something ready tomorrow.  My latest patch actually replaces the final
>'return 0' with a call to a function that will return true if the send=
er
>was the device that received it.  This will hopefully prevent some of
>the failures with the first patch I posted.  I'll know a bit more
>tomorrow if this approach seems reasonable.

	How do you figure that out?  In -rr mode, all of the slaves
should have the same MAC address, and the slaves shouldn't be running
IPv6 addrconf separately from the master anyway.  Something magic just
for NA/NS packets?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
