From: Christian =?iso-8859-1?q?Borntr=E4ger?= <christian@borntraeger.net>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Tue, 18 Jan 2005 16:53:58 +0100
Message-ID: <200501181653.59041.christian@borntraeger.net>
References: <20050116115431.GA13617@lst.de> <200501180037.58453.christian@borntraeger.net> <1106009385.1046.49.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>,
        pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106009385.1046.49.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Frank, please correct me, if I am wrong....

jamal wrote:
> On Mon, 2005-01-17 at 18:37, Christian Borntr=E4ger wrote:
> > I am trying a small simplification here:
> > Each physical network adapter offers hundreds of device addresses. Yo=
u
> > need 3 of them to have one logical network adapter(read,write,data).
>
> the "card" concept is what you call network adapter, correct?
> I take it that read and write are control channels and data is where th=
e
> skb comes through?

don't ask me about naming....

> >  S/390 has
> > hardware supported virtualization. Therefore can then use the
> > hypervisor (LPAR or z/VM) to give specific LPARs or VM guests exactly=
 3
> > device addresses out of these hundreds.
>
> Can you provision multiple of these cards per VM? if yes, is there some
> ID that will break it down to OSInstance:cardid?
> > The qeth driver has to register the IP address at the logical network
> > card (using 3 device addresses) Afterwards the physical network card
> > knows which packet belongs to which device numbers.
>
> I think i understood  but confused: before you attach IP address though=
,
> you cant receive packets? Is there a concept of MAC address which you
> can pass to the hypervisor or can you run in promiscmous mode?

Right, without registering the IP address, you can not receive any packet.
As the logical network interface has no own MAC address you actually spea=
k=20
IP to the card. That also means, that without some additional effort, too=
ls=20
like tcpdump fail and you need some patches in the dhcp tools.=20
You can define options for routers to get more than your own packages, bu=
t=20
IIRC you can only define a primary and secondary router per port.=20

>
> Another question: When that driver runs for the physical card - it runs

The driver never ever runs for the physical card. It runs for 3 devices=20
addresses, which are already behind a layer of virtualization and represe=
nt=20
a logical IP stack in the physical card. To Linux it looks like a physica=
l=20
card.=20

> in the context of a specific VM, correct? In other words it would be
> impossible to see the "card" of another instance?

By VM you mean virtual machine? Right. We are talking about real hardware=
=20
emulation. Think about it as VMWARE in hardware or with hardware support.
So you have no access to logical cards of other Linuxes.=20
One difference to real hardware is, that multiple Linuxes have the same M=
AC=20
address. The physical OSA network card and z/VM ensure, that incoming=20
packets are delivered to the right Linux.=20


cheers=20
Christian
