From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 10:53:56 -0400
Message-ID: <CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
	<CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
	<CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38149 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbbCZOx5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 10:53:57 -0400
Received: by wibgn9 with SMTP id gn9so89033306wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 07:53:56 -0700 (PDT)
In-Reply-To: <CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 10:39 AM, Bj=C3=B8rnar Ness <bjornar.ness@gmail=
=2Ecom> wrote:

>>> ip route add 10.0.0.0/16 via fe80::225:90ff:fed3:bfb4/64 dev sfp0
>>
>> Trying to understand what the desired behavior is, for the route
>> above: if I send a packet from 10.0.0.1 to 10.0.0.2, you want the ds=
t-mac
>> to be the mac address of e80::225:90ff:fed3:bfb4???
>
> Absolutely, correct.

What if the current node does not want to support ipv6? This sounds
pretty "creative", if this can work, you might as well make the nexthop=
 to
be the L2 address of the gw.


> Basically because you either added the route manually, or it was prov=
ided
> by fe80::225:90ff:fed3:bfb4 itself via some routing protocol (MP-BGP)
>
> This will be the same as any other route. How do you know it forwards=
 traffic..

because you would be running a routing protocol that manages reachabili=
ty
of the gw and the route. RIP, OSPF, BGP etc all have a lot of mechanism=
s
to monitor liveness of the route and of the nexthop, which has to be of
the same address family as the route itself.

>
> In large routed setups, address management in general and lack of IPv=
4 addresses
> can become a big hassle. Beeing able to get a ipv6 neighbor for a ipv=
4
> route would
> make this process a lot simpler.

Yes, that's the motivation behind all the tunneling/transition mechanis=
ms
in the various ipv6 working groups.

--Sowmini
