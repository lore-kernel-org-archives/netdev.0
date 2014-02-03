From: Sohny Thomas <sthomas@linux.vnet.ibm.com>
Subject: Re: [PATCH] ipv6: default route for link local address is not added
 while assigning a address
Date: Mon, 03 Feb 2014 12:49:27 +0530
Message-ID: <52EF42FF.60907@linux.vnet.ibm.com>
References: <52E8A2AA.3090507@linux.vnet.ibm.com> <52E8DA37.7010208@6wind.com> <20140130232909.GH25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140130232909.GH25336@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Actually I am not so sure, there is no defined semantic of flush. I would
> be ok with all three solutions: leave it as is, always add link-local
> address (it does not matter if we don't have a link-local address on
> that interface, as a global scoped one is just fine enough) or make flush not
> remove the link-local address (but this seems a bit too special cased for me).

1) In case if we leave it as it is, there is rfc 6724 rule 2 to be 
considered ( previously rfc 3484)

Rule 2: Prefer appropriate scope.
    If Scope(SA) < Scope(SB): If Scope(SA) < Scope(D), then prefer SB and
    otherwise prefer SA.  Similarly, if Scope(SB) < Scope(SA): If
    Scope(SB) < Scope(D), then prefer SA and otherwise prefer SB.

Test:

    Destination: fe80::2(LS)
     Candidate Source Addresses: 3ffe::1(GS) or fec0::1(SS) or LLA(LS)
     Result: LLA(LS)
     Scope(LLA) < Scope(fec0::1): If Scope(LLA) < Scope(fe80::2),  no, 
prefer LLA
     Scope(LLA) < Scope(3ffe::1): If Scope(LLA) < Scope(fe80::2),  no, 
prefer LLA


Now the above test fails since the route itself is not present, and the 
test assumes that the route gets added since the LLA is not removed 
during the test

2) having a LLA always helps in NDP i think

3) making flush not remove link-local address will be chnaging 
functionality of ip flush command

Regards,
Sohny

>
> Greetings,
>
>    Hannes
>
>
>
