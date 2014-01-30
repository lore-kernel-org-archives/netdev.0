From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: default route for link local address is not added while assigning a address
Date: Fri, 31 Jan 2014 00:29:09 +0100
Message-ID: <20140130232909.GH25336@order.stressinduktion.org>
References: <52E8A2AA.3090507@linux.vnet.ibm.com> <52E8DA37.7010208@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52E8DA37.7010208@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for replying so late...

On Wed, Jan 29, 2014 at 11:38:47AM +0100, Nicolas Dichtel wrote:
> Le 29/01/2014 07:41, Sohny Thomas a =C3=A9crit :
> >Resending this on netdev mailing list:
> >Default route for link local address is configured automatically if
> >NETWORKING_IPV6=3Dyes is in ifcfg-eth*.
> >When the route table for the interface is flushed and a new address =
is=20
> >added to
> >the same device with out removing linklocal addr, default route for =
link=20
> >local
> >address has to added by default.
> >
> >I have found the issue to be caused by this checkin
> >
> >http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/net/ipv6?id=3D62b54dd91567686a1cb118f76a72d5f4764a86dd
> >
> >
> >According to this change :
> >He removes adding a link local route if any other address is added ,=
=20
> >applicable
> >across all interfaces though there's mentioned only lo interface
> >So below patch fixes for other devices
> >
> >Signed-off-by: Sohny THomas <sohthoma@linux.vnet.ibm.com>
> Your email client has corrupted the patch, it cannot be applied.
> Please read Documentation/email-clients.txt
>=20
> About the patch, I still think that the flush is too agressive. Link =
local
> routes are marked as 'proto kernel', removing them without the link l=
ocal
> address is wrong.

Actually I am not so sure, there is no defined semantic of flush. I wou=
ld
be ok with all three solutions: leave it as is, always add link-local
address (it does not matter if we don't have a link-local address on
that interface, as a global scoped one is just fine enough) or make flu=
sh not
remove the link-local address (but this seems a bit too special cased f=
or me).

Greetings,

  Hannes
