From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 12 Jul 2004 22:26:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089685567.1046.9.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <200407092126.43021.vkondra@mail.ru>
	 <1089634701.1055.260.camel@jzny.localdomain>
	 <200407122107.29389.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407122107.29389.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-12 at 14:07, Vladimir Kondratiev wrote:

> > That or if routed from another host, then TOS does get extracted and set
> > to skb->priority
> this is not very important. From one side, it seems like bug in routing code. 
> - From another side, 802.11 was supposed for link ends only. It is not supposed 
> to appear in the middle of routers chain.

I dont see the bug - this is pretty standard.
Actually there is one issue, now that i think of it. The way IEEE
maps priority is the opposite of the way IETF does it ;->
If you have 8 priorities then priority 7 would be the highest in 
IEEE speak (i.e most important) but priority 0 would be the one
considered most important for IEEE. so a strict TOS -> skb->priority
wont work ;->


> > I dont think so - as long as you map to a specific qdisc things should
> > work fine. i.e the scheduling semantics will be taken good care of by
> > the qdisc level.
> > So lets separate the two levels, driver and qdisc level.
> > I dont think they should be synchronized. In my opinion, the
> > synchronization point is the configurator/operator/management s/ware of
> > the box.
> QoS policies are dictated by access point, they are coming to the driver from 
> the link side. And I see no way to let upper layers to know these policies.

Huh? Are these speacial L2 level frames which carry the policy?
Sounds like the people doing this were on some cheap crack.
Can you describe these frames a little more?

> > - Shut down device only when highest(1) priority ring is full.
> > - if packets received for priority 2 and 3 and their respective rings
> > are full, drop the packet in the driver and return a 0 i.e dont shut
> > device.
> Real situation:
> - - highest priority is VOIP (200 bytes each 20ms). With decent link, it will 
> always pass.
> - - low priority is ftp bulk transfer. stack pushes more then driver can tx. I 
> will silently drop 9 out of 10 packets. Not a good behavior.

Thats the definition of strict priority.
In other words if theres VOIP packet you always send VOIP untuil theres
no more VOIP. Only then you send ftp packets.
On the case of WRR, you do give some break to ftp at some point. But
this is not something you have to worry about once the qdiscs are
configured properly.

> >
> > You can also do the following in the case of strict priority(caveat is
> > reordering may happen):
> > for each prio X try to stash on DMA ring of prio X. If full, try X+1, if
> > full try X+2 etc.
> forbidden by spec. I will be disconnected immediately.

Ok.

cheers,
jamal
