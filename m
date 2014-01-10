From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ipv6: default route for link local address is not added while
 assigning a address
Date: Fri, 10 Jan 2014 17:33:08 +0100
Message-ID: <52D020C4.30105@6wind.com>
References: <52CFE594.8010808@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kumuda <kumuda@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: sohny thomas <sohny.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CFE594.8010808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: netdev

Le 10/01/2014 13:20, sohny thomas a =E9crit :
> Default route for link local address is configured automatically if
> NETWORKING_IPV6=3Dyes is in ifcfg-eth*.
> When the route table for the interface is flushed and a new address i=
s added to
> the same device with out removing linklocal addr, default route for l=
ink local
> address has to added by default.
I would say that removing the link local route but not the link local a=
ddress
is a configuration problem.
If you remove a connected route but not the associated address, you wil=
l have
the same problem.

>
> I have found the issue to be caused by this checkin
>
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit=
/net/ipv6?id=3D62b54dd91567686a1cb118f76a72d5f4764a86dd
>
>
> According to this change :
> He removes adding a link local route if any other address is added , =
applicable
> across all interfaces though there's mentioned only lo interface
> So below patch fixes for other devices
