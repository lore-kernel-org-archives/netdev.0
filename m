From: Frank Pavlic <PAVLIC@de.ibm.com>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Tue, 18 Jan 2005 19:25:25 +0100
Message-ID: <OF9CE4F704.A1A329E2-ON41256F8D.0065082C-41256F8D.0065346B@de.ibm.com>
References: <200501181653.59041.christian@borntraeger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, waldi@debian.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <200501181653.59041.christian@borntraeger.net>
To: Christian =?ISO-8859-1?Q?Borntr=E4ger?= <christian@borntraeger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org








Christian Borntr=E4ger <christian@borntraeger.net> wrote on 18.01.2005
16:53:58:

> Frank, please correct me, if I am wrong....

It's all correct ....
sorry Christian but I didn't make it to answer :-(

>
> jamal wrote:
> > On Mon, 2005-01-17 at 18:37, Christian Borntr=E4ger wrote:
> > > I am trying a small simplification here:
> > > Each physical network adapter offers hundreds of device addresses.
You
> > > need 3 of them to have one logical network adapter(read,write,data).
> >
> > the "card" concept is what you call network adapter, correct?
> > I take it that read and write are control channels and data is where
the
> > skb comes through?
>
> don't ask me about naming....
>
> > >  S/390 has
> > > hardware supported virtualization. Therefore can then use the
> > > hypervisor (LPAR or z/VM) to give specific LPARs or VM guests exact=
ly
3
> > > device addresses out of these hundreds.
> >
> > Can you provision multiple of these cards per VM? if yes, is there so=
me
> > ID that will break it down to OSInstance:cardid?
> > > The qeth driver has to register the IP address at the logical netwo=
rk
> > > card (using 3 device addresses) Afterwards the physical network car=
d
> > > knows which packet belongs to which device numbers.
> >
> > I think i understood  but confused: before you attach IP address
though,
> > you cant receive packets? Is there a concept of MAC address which you
> > can pass to the hypervisor or can you run in promiscmous mode?
>
> Right, without registering the IP address, you can not receive any
packet.
> As the logical network interface has no own MAC address you actually
speak
> IP to the card. That also means, that without some additional effort,
tools
> like tcpdump fail and you need some patches in the dhcp tools.
> You can define options for routers to get more than your own packages,
but
> IIRC you can only define a primary and secondary router per port.
>
> >
> > Another question: When that driver runs for the physical card - it ru=
ns
>
> The driver never ever runs for the physical card. It runs for 3 devices
> addresses, which are already behind a layer of virtualization and
represent
> a logical IP stack in the physical card. To Linux it looks like a
physical
> card.
>
> > in the context of a specific VM, correct? In other words it would be
> > impossible to see the "card" of another instance?
>
> By VM you mean virtual machine? Right. We are talking about real hardwa=
re

> emulation. Think about it as VMWARE in hardware or with hardware suppor=
t.
> So you have no access to logical cards of other Linuxes.
> One difference to real hardware is, that multiple Linuxes have the same
MAC
> address. The physical OSA network card and z/VM ensure, that incoming
> packets are delivered to the right Linux.
>
>
> cheers
> Christian
