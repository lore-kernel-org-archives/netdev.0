From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 16:10:21 +0100
Message-ID: <CAJO99Tm+ex7aELCrNnubWz1hGjELMp0LCMKSqtyr+Vci1hrmuw@mail.gmail.com>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
	<CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
	<CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
	<CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35897 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbbCZPKW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 11:10:22 -0400
Received: by labe2 with SMTP id e2so47874646lab.3
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 08:10:21 -0700 (PDT)
In-Reply-To: <CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-26 15:53 GMT+01:00 Sowmini Varadhan <sowmini05@gmail.com>:
> On Thu, Mar 26, 2015 at 10:39 AM, Bj=C3=B8rnar Ness <bjornar.ness@gma=
il.com> wrote:
>
>>>> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp0
>>>
>>> Trying to understand what the desired behavior is, for the route
>>> above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want the d=
st-mac
>>> to be the mac address of e80::225:90ff:fed3:bfb4???
>>
>> Absolutely, correct.
>
> What if the current node does not want to support ipv6? This sounds
> pretty "creative", if this can work, you might as well make the nexth=
op to
> be the L2 address of the gw.

If it does not support IPv6 I guess the route command will fail! This
is a bad argument
against this. Dont see the point of limiting nexthop to L2

>> Basically because you either added the route manually, or it was pro=
vided
>> by fe80::225:90ff:fed3:bfb4 itself via some routing protocol (MP-BGP=
)
>>
>> This will be the same as any other route. How do you know it forward=
s traffic..
>
> because you would be running a routing protocol that manages reachabi=
lity
> of the gw and the route. RIP, OSPF, BGP etc all have a lot of mechani=
sms
> to monitor liveness of the route and of the nexthop, which has to be =
of
> the same address family as the route itself.

Did you look at RFC5549 and MP-BGP?

>> In large routed setups, address management in general and lack of IP=
v4 addresses
>> can become a big hassle. Beeing able to get a ipv6 neighbor for a ip=
v4
>> route would
>> make this process a lot simpler.
>
> Yes, that's the motivation behind all the tunneling/transition mechan=
isms
> in the various ipv6 working groups.

Point is we dont need another software encapsulation for this to work.
It can work
more or less "out-of-the-box" if ipv4 nexthops can be ipv6

Say you have 10 racks with 40 servers in each, two links to each
server to each TOR,
and you want to run a full L3 BGP routed network here. The
configuration/addressing
overhead we need today is enormous. With neighbor discovery and IPv6 ne=
xthops,
this configuration can be done totally dynamic using link-local address=
es.

I know people are working on this, but as I wrote in the first mail, I
just hope it gets done
"right", not hacky like this (POC):

https://ams-ix.net/downloads/RFC5549/

--=20
Bj(/)rnar
