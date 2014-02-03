From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv6: default route for link local address is not added
 while assigning a address
Date: Mon, 03 Feb 2014 16:23:00 +0100
Message-ID: <52EFB454.1040908@6wind.com>
References: <52E8A2AA.3090507@linux.vnet.ibm.com> <52E8DA37.7010208@6wind.com> <20140130232909.GH25336@order.stressinduktion.org> <52EF42FF.60907@linux.vnet.ibm.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EF42FF.60907@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/02/2014 08:19, Sohny Thomas a =C3=A9crit :
>
>> Actually I am not so sure, there is no defined semantic of flush. I =
would
>> be ok with all three solutions: leave it as is, always add link-loca=
l
>> address (it does not matter if we don't have a link-local address on
It matters. This address is required.
RFC 4291
Section 2.1:
    All interfaces are required to have at least one Link-Local unicast
    address (see Section 2.8 for additional required addresses).
Section 2.8:
       o Its required Link-Local address for each interface.

>> that interface, as a global scoped one is just fine enough) or make =
flush not
>> remove the link-local address (but this seems a bit too special case=
d for me).
>
> 1) In case if we leave it as it is, there is rfc 6724 rule 2 to be co=
nsidered (
> previously rfc 3484)
>
> Rule 2: Prefer appropriate scope.
>     If Scope(SA) < Scope(SB): If Scope(SA) < Scope(D), then prefer SB=
 and
>     otherwise prefer SA.  Similarly, if Scope(SB) < Scope(SA): If
>     Scope(SB) < Scope(D), then prefer SA and otherwise prefer SB.
>
> Test:
>
>     Destination: fe80::2(LS)
>      Candidate Source Addresses: 3ffe::1(GS) or fec0::1(SS) or LLA(LS=
)
>      Result: LLA(LS)
>      Scope(LLA) < Scope(fec0::1): If Scope(LLA) < Scope(fe80::2),  no=
, prefer LLA
>      Scope(LLA) < Scope(3ffe::1): If Scope(LLA) < Scope(fe80::2),  no=
, prefer LLA
>
>
> Now the above test fails since the route itself is not present, and t=
he test
> assumes that the route gets added since the LLA is not removed during=
 the test
In your scenario, the link local route has been removed manually, not b=
y the
kernel. What is your network manager?

>
> 2) having a LLA always helps in NDP i think
A link-local Address yes, it's a MUST. But having only the link local r=
oute will
not help.

>
> 3) making flush not remove link-local address will be chnaging functi=
onality of
> ip flush command
You can flush by specifying the prototype:
ip -6 route flush proto static


Regards,
Nicolas
